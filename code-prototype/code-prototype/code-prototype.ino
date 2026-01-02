#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>

#include "MAX30105.h"
#include "spo2_algorithm.h"     // maxim_heart_rate_and_oxygen_saturation(...)
#include <Adafruit_MLX90614.h>

/* ========= WiFi ========= */
const char* ssid     = "Oppo";
const char* wifiPass = "AZiz1234..?";

/* ========= MQTT (HiveMQ public broker) ========= */
const char* mqttHost = "broker.hivemq.com";
const int   mqttPort = 1883;

WiFiClient   espClient;
PubSubClient mqtt(espClient);

/* ========= Sensors ========= */
MAX30105 particleSensor;
Adafruit_MLX90614 mlx;

/* ========= MAX30102 settings ========= */
const byte ledMode       = 2;    // Red + IR
const byte sampleAverage = 4;
const byte sampleRate    = 25;   // 25Hz
const int  pulseWidth    = 411;
const int  adcRange      = 16384;

/* ========= Buffer (4 seconds at 25Hz => 100 samples) ========= */
static const int PPG_BUF_SIZE = 100;
uint32_t irBuffer[PPG_BUF_SIZE];
uint32_t redBuffer[PPG_BUF_SIZE];

int32_t spo2Calc = 0, hrCalc = 0;
int8_t  validSPO2 = 0, validHR = 0;

static const unsigned long PUBLISH_EVERY_MS = 4000;
unsigned long lastPub = 0;

/* ========= Simple smoothing / bounds ========= */
int   lastHrGood   = 0;
int   lastSpGood   = 0;
float lastTempGood = NAN;

const int   HR_MIN = 40, HR_MAX = 180;
const int   SPO2_MIN = 85, SPO2_MAX = 100;
const float ALPHA_HR   = 0.4f;
const float ALPHA_TEMP = 0.3f;

/* ========= LED amplitudes (auto gain) ========= */
uint8_t irAmp  = 0x50;
uint8_t redAmp = 0x50;

inline void applyLedAmplitude() {
  particleSensor.setPulseAmplitudeIR(irAmp);
  particleSensor.setPulseAmplitudeRed(redAmp);
}

inline void autoTune(uint32_t meanIR, uint32_t meanRed) {
  if (meanIR < 15000 && irAmp < 0xF0) irAmp += 8;
  else if (meanIR > 150000 && irAmp > 0x10) irAmp -= 8;

  if (meanRed < meanIR * 7 / 10 && redAmp < 0xF0) redAmp += 8;
  else if (meanRed > meanIR * 13 / 10 && redAmp > 0x10) redAmp -= 8;

  applyLedAmplitude();
}

/* ========= DeviceId + Topics ========= */
String deviceId;       // esp32-<12hex> lower
String topicVitals;    // iot/vitals/<deviceId>
String topicRealtime;  // iot/vitals/<deviceId>/realtime
String topicStatus;    // iot/status/<deviceId>
String topicCommands;  // iot/commands/<deviceId>

/* ========= Helpers ========= */
String makeDeviceId() {
  uint64_t mac = ESP.getEfuseMac();
  char hex[13];
  snprintf(hex, sizeof(hex), "%012llX", (unsigned long long)mac);
  String id = "esp32-";
  id += String(hex);
  id.toLowerCase();
  return id;
}

void connectWifi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, wifiPass);

  Serial.print("[WiFi] connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(250);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("[WiFi] OK, IP = ");
  Serial.println(WiFi.localIP());
}

/* Read object temp with smoothing */
bool readObjectTempC(float &out) {
  out = NAN;
  for (int i = 0; i < 3; i++) {
    float v = mlx.readObjectTempC();
    if (!isnan(v)) {
      if (isnan(lastTempGood)) lastTempGood = v;
      else lastTempGood = lastTempGood + ALPHA_TEMP * (v - lastTempGood);
      out = lastTempGood;
      return true;
    }
    delay(5);
  }
  return false;
}

/* Acquire 4s worth of samples and compute HR + SpO2 */
void acquireHRSpO2Once(int &hrOut, int &spo2Out, bool &fingerOut) {
  int i = 0;
  while (i < PPG_BUF_SIZE) {
    if (particleSensor.available()) {
      redBuffer[i] = particleSensor.getRed();
      irBuffer[i]  = particleSensor.getIR();
      particleSensor.nextSample();
      i++;
    } else {
      particleSensor.check();
    }
  }

  uint64_t sumIR=0, sumRed=0, sqIR=0;
  for (int k = 0; k < PPG_BUF_SIZE; k++) {
    sumIR  += irBuffer[k];
    sumRed += redBuffer[k];
    sqIR   += (uint64_t)irBuffer[k] * irBuffer[k];
  }

  uint32_t meanIR  = sumIR / PPG_BUF_SIZE;
  uint32_t meanRed = sumRed / PPG_BUF_SIZE;

  float varIR = (float)sqIR / PPG_BUF_SIZE - (float)meanIR * meanIR;
  if (varIR < 0) varIR = 0;
  float stdIR = sqrtf(varIR);

  // finger detection
  fingerOut = (meanIR > 20000) && (stdIR > 50);

  autoTune(meanIR, meanRed);

  maxim_heart_rate_and_oxygen_saturation(
    irBuffer, PPG_BUF_SIZE, redBuffer,
    &spo2Calc, &validSPO2, &hrCalc, &validHR
  );

  int hrRaw = (validHR ? (int)hrCalc : 0);
  int spRaw = (validSPO2 ? (int)spo2Calc : 0);

  int hrOk = 0, spOk = 0;

  if (fingerOut && hrRaw >= HR_MIN && hrRaw <= HR_MAX) {
    hrOk = (lastHrGood == 0) ? hrRaw : (int)(lastHrGood + ALPHA_HR * (hrRaw - lastHrGood));
    lastHrGood = hrOk;
  }

  if (fingerOut && spRaw >= SPO2_MIN && spRaw <= SPO2_MAX) {
    spOk = (lastSpGood == 0) ? spRaw : (int)(lastSpGood + ALPHA_HR * (spRaw - lastSpGood));
    lastSpGood = spOk;
  }

  hrOut   = hrOk;
  spo2Out = spOk;
}

/* Publish vitals (normal / realtime) */
bool publishVitals(bool realtime) {
  int hr = 0, sp = 0;
  bool finger = false;
  acquireHRSpO2Once(hr, sp, finger);

  float tempC;
  bool okT = mlx.begin() ? readObjectTempC(tempC) : false; // safe

  char json[256];
  if (okT) {
    snprintf(json, sizeof(json),
      "{\"deviceId\":\"%s\",\"timestamp\":%lu,\"realtime\":%s,"
      "\"heartRate\":%d,\"spo2\":%d,\"temperature\":%.2f,\"finger\":%s}",
      deviceId.c_str(),
      millis(),
      realtime ? "true" : "false",
      hr, sp, tempC,
      finger ? "true" : "false"
    );
  } else {
    snprintf(json, sizeof(json),
      "{\"deviceId\":\"%s\",\"timestamp\":%lu,\"realtime\":%s,"
      "\"heartRate\":%d,\"spo2\":%d,\"temperature\":null,\"finger\":%s}",
      deviceId.c_str(),
      millis(),
      realtime ? "true" : "false",
      hr, sp,
      finger ? "true" : "false"
    );
  }

  const char* t = realtime ? topicRealtime.c_str() : topicVitals.c_str();
  bool ok = mqtt.connected() && mqtt.publish(t, json);

  Serial.printf("[PUB] %s -> %s | HR=%d SpO2=%d Temp=%s Finger=%s MQTT=%s\n",
                realtime ? "REALTIME" : "NORMAL",
                t,
                hr, sp,
                okT ? String(tempC,2).c_str() : "null",
                finger ? "true" : "false",
                ok ? "OK" : "FAIL");
  return ok;
}

/* MQTT callback (commands) */
void mqttCallback(char* topic, byte* payload, unsigned int length) {
  String msg;
  msg.reserve(length);
  for (unsigned int i = 0; i < length; i++) msg += (char)payload[i];
  msg.trim();

  String t = String(topic);
  if (t == topicCommands) {
    Serial.printf("[CMD] %s => %s\n", topic, msg.c_str());
    if (msg.equalsIgnoreCase("read")) {
      publishVitals(true);
    }
  }
}

/* MQTT connect with LWT and retained ONLINE */
bool ensureMqtt() {
  if (mqtt.connected()) return true;

  static unsigned long lastTry = 0;
  if (millis() - lastTry < 3000) return false;
  lastTry = millis();

  Serial.printf("[MQTT] connecting %s:%d ... ", mqttHost, mqttPort);

  // LWT = OFFLINE (retained)
  bool ok = mqtt.connect(
    deviceId.c_str(),
    topicStatus.c_str(), 1, true, "OFFLINE"
  );

  if (!ok) {
    Serial.printf("FAIL rc=%d\n", mqtt.state());
    return false;
  }

  Serial.println("OK");

  mqtt.subscribe(topicCommands.c_str(), 1);

  // publish ONLINE retained
  mqtt.publish(topicStatus.c_str(), "ONLINE", true);

  return true;
}

/* =================== Setup =================== */
void setup() {
  Serial.begin(115200);
  delay(200);

  Wire.begin();
  Wire.setClock(100000);

  deviceId = makeDeviceId();

  topicVitals   = "iot/vitals/"   + deviceId;
  topicRealtime = "iot/vitals/"   + deviceId + "/realtime";
  topicStatus   = "iot/status/"   + deviceId;
  topicCommands = "iot/commands/" + deviceId;

  Serial.println("=== BabyGuardian ESP32 ===");
  Serial.println("deviceId      = " + deviceId);
  Serial.println("topicVitals   = " + topicVitals);
  Serial.println("topicRealtime = " + topicRealtime);
  Serial.println("topicStatus   = " + topicStatus);
  Serial.println("topicCommands = " + topicCommands);

  connectWifi();

  mqtt.setServer(mqttHost, mqttPort);
  mqtt.setKeepAlive(30);
  mqtt.setCallback(mqttCallback);

  // MAX30102
  if (!particleSensor.begin(Wire, I2C_SPEED_STANDARD)) {
    Serial.println("[ERR] MAX30102 not found (SDA=21 SCL=22).");
    while (true) delay(10);
  }
  particleSensor.setup(60, sampleAverage, ledMode, sampleRate, pulseWidth, adcRange);
  applyLedAmplitude();

  // MLX90614
  if (!mlx.begin()) {
    Serial.println("[WARN] MLX90614 not detected (temperature will be null).");
  } else {
    Serial.println("[OK] MLX90614 detected.");
  }

  Serial.println("[OK] Sensors initialized.");
}

/* =================== Loop =================== */
void loop() {
  if (!ensureMqtt()) {
    delay(50);
    return;
  }

  mqtt.loop();

  if (millis() - lastPub >= PUBLISH_EVERY_MS) {
    lastPub = millis();
    publishVitals(false);
  }
}
