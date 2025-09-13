#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>
#include "MAX30105.h"
#include "heartRate.h"
#include "spo2_algorithm.h"
#include <Adafruit_MLX90614.h>

/* ========= Réseau ========= */
const char* ssid        = "HATEM R";
const char* password    = "74671771";
const char* mqtt_server = "broker.hivemq.com";
const int   mqtt_port   = 1883;
const char* topic       = "iot/vitals/device1";

/* ========= Objets ========= */
WiFiClient      espClient;
PubSubClient    client(espClient);
MAX30105        particleSensor;
Adafruit_MLX90614 mlx;

/* ========= MAX30102 (optimisé SpO2) =========
   - 25 Hz, fenêtre 4 s (100 échantillons) */
const byte ledMode       = 2;    // Red + IR
const byte sampleAverage = 4;
const byte sampleRate    = 25;   // 25 Hz
const int  pulseWidth    = 411;
const int  adcRange      = 16384;

/* ========= Fenêtre / publication ========= */
const int   PPG_BUF_SIZE   = 100;     // 100 échantillons -> ~4 s à 25 Hz
const unsigned long PUBLISH_EVERY_MS = 4000;

uint32_t irBuffer[PPG_BUF_SIZE], redBuffer[PPG_BUF_SIZE];
int32_t  spo2Calc = 0, heartRateCalc = 0;
int8_t   validSPO2 = 0, validHR = 0;

/* ========= LED auto-gain ========= */
uint8_t irAmp  = 0x50; // ~80/255
uint8_t redAmp = 0x50;
inline void applyLedAmplitude() {
  particleSensor.setPulseAmplitudeIR(irAmp);
  particleSensor.setPulseAmplitudeRed(redAmp);
}
inline void autoTune(uint32_t meanIR, uint32_t meanRed) {
  // IR vers 20k-120k
  if (meanIR < 15000 && irAmp < 0xF0) irAmp += 8;
  else if (meanIR > 150000 && irAmp > 0x10) irAmp -= 8;
  // Red proche d'IR (±30 %)
  if (meanRed < meanIR*7/10 && redAmp < 0xF0) redAmp += 8;
  else if (meanRed > meanIR*13/10 && redAmp > 0x10) redAmp -= 8;
  applyLedAmplitude();
}

/* ========= Lissage & bornes ========= */
int   lastHrGood   = 0;
int   lastSpGood   = 0;
float lastTempGood = NAN;

const int   HR_MIN = 40, HR_MAX = 180;
const int   SPO2_MIN = 85, SPO2_MAX = 100;
const float ALPHA_TEMP = 0.3f;  // 0..1 (plus grand = plus réactif)
const float ALPHA_HR   = 0.4f;

/* ========= Utilitaires ========= */
void connectWifi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("WiFi...");
  while (WiFi.status() != WL_CONNECTED) { delay(250); Serial.print("."); }
  Serial.print("\nWiFi ok, IP = "); Serial.println(WiFi.localIP());
}

bool tryMqttConnect() {
  if (client.connected()) return true;

  static unsigned long lastTry = 0;
  if (millis() - lastTry < 5000) return false;  // 1 essai / 5 s
  lastTry = millis();

  // Test TCP brut avant MQTT
  Serial.printf("[MQTT] TCP test %s:%d ... ", mqtt_server, mqtt_port);
  WiFiClient probe;
  if (probe.connect(mqtt_server, mqtt_port)) {
    Serial.println("TCP OK");
    probe.stop();
  } else {
    Serial.println("TCP FAIL -> pare-feu/routeur bloque");
    return false; // Inutile d'essayer MQTT si TCP échoue
  }

  // Essai MQTT
  String cid = "ESP32-" + String((uint32_t)ESP.getEfuseMac(), HEX);
  Serial.print("[MQTT] client.connect ... ");
  bool ok = client.connect(cid.c_str());  // anonyme
  if (ok) Serial.println("OK");
  else    Serial.printf("ECHEC rc=%d\n", client.state());  // rc=-2 = échec socket
  return ok;
}


bool readObjectTempC(float &out) {
  out = NAN;
  for (int i=0;i<3;i++) {
    float v = mlx.readObjectTempC();
    if (!isnan(v)) {
      if (isnan(lastTempGood)) lastTempGood = v;
      else lastTempGood = lastTempGood + ALPHA_TEMP*(v - lastTempGood);
      out = lastTempGood;
      return true;
    }
    delay(5);
  }
  return false;
}

/* ===== Acquisition (4 s) + calcul HR/SpO2 ===== */
void acquireHRSpO2Once(int &hrOut, int &spo2Out, bool &finger) {
  int i = 0;
  while (i < PPG_BUF_SIZE) {
    if (particleSensor.available()) {
      redBuffer[i] = particleSensor.getRed();
      irBuffer[i]  = particleSensor.getIR();
      particleSensor.nextSample();
      i++;
    } else {
      particleSensor.check(); // remplit FIFO
    }
  }

  uint64_t sumIR=0, sumRed=0, sqIR=0;
  for (int k=0;k<PPG_BUF_SIZE;k++) {
    sumIR  += irBuffer[k];
    sumRed += redBuffer[k];
    sqIR   += (uint64_t)irBuffer[k]*irBuffer[k];
  }
  uint32_t meanIR  = sumIR / PPG_BUF_SIZE;
  uint32_t meanRed = sumRed / PPG_BUF_SIZE;
  float varIR = (float)sqIR/PPG_BUF_SIZE - (float)meanIR*meanIR; if (varIR < 0) varIR = 0;
  float stdIR = sqrtf(varIR);

  finger = (meanIR > 20000) && (stdIR > 50);     // présence + un peu d’amplitude
  autoTune(meanIR, meanRed);                     // prépare la fenêtre suivante

  maxim_heart_rate_and_oxygen_saturation(
    irBuffer, PPG_BUF_SIZE, redBuffer,
    &spo2Calc, &validSPO2, &heartRateCalc, &validHR
  );

  int hrRaw = (validHR ? (int)heartRateCalc : 0);
  int spRaw = (validSPO2 ? (int)spo2Calc : 0);

  // Filtrage bio + lissage
  int hrOk = 0, spOk = 0;
  if (finger && hrRaw >= HR_MIN && hrRaw <= HR_MAX) {
    hrOk = (lastHrGood == 0) ? hrRaw : (int)(lastHrGood + ALPHA_HR*(hrRaw - lastHrGood));
    lastHrGood = hrOk;
  }
  if (finger && spRaw >= SPO2_MIN && spRaw <= SPO2_MAX) {
    spOk = (lastSpGood == 0) ? spRaw : (int)(lastSpGood + ALPHA_HR*(spRaw - lastSpGood));
    lastSpGood = spOk;
  }
  hrOut   = hrOk;
  spo2Out = spOk;
}

/* ================== Setup ================== */
void setup() {
  Serial.begin(115200);
  delay(200);

  Wire.begin();          // SDA=21, SCL=22 par défaut
  Wire.setClock(100000); // 100 kHz (stable)

  connectWifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setKeepAlive(30);

  if (!particleSensor.begin(Wire, I2C_SPEED_STANDARD)) {
    Serial.println("MAX30102 introuvable (SDA=21 SCL=22 3V3 GND).");
    while (1) delay(10);
  }
  // brightness est ajusté automatiquement par irAmp/redAmp
  particleSensor.setup( /*brightness*/ 60, sampleAverage, ledMode,
                        sampleRate, pulseWidth, adcRange);
  applyLedAmplitude();

  if (!mlx.begin()) {
    Serial.println("MLX90614 non détecté (température = null).");
  }

  Serial.println("Capteurs initialisés.");
}

/* ================== Loop ================== */
void loop() {
  tryMqttConnect();
  client.loop();

  static unsigned long lastPub = 0;
  if (millis() - lastPub >= PUBLISH_EVERY_MS) {
    lastPub = millis();

    // 1) Mesures
    int hr = 0, sp = 0; bool finger=false;
    acquireHRSpO2Once(hr, sp, finger);

    float tempC; bool okT = readObjectTempC(tempC);

    // 2) JSON
    char json[200];
    if (okT) snprintf(json, sizeof(json),
        "{\"heartRate\":%d,\"spo2\":%d,\"temperature\":%.2f}", hr, sp, tempC);
    else     snprintf(json, sizeof(json),
        "{\"heartRate\":%d,\"spo2\":%d,\"temperature\":null}", hr, sp);

    // 3) Publish + affichage simple
    bool mqttOk = client.connected() && client.publish(topic, json);

    // Affichage compact et lisible
    Serial.printf("HR:%3d bpm | SpO2:%3d%% | Temp:%s | Doigt:%s | MQTT:%s\n",
                  hr,
                  sp,
                  okT ? String(tempC, 2).c_str() : "null",
                  finger ? "oui" : "non",
                  mqttOk ? "ok" : "off");
  }
}
