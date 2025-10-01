// src/main/java/org/babyguardianbackend/sensorservice/mqttConfig/MqttInboundHandler.java
package org.babyguardianbackend.sensorservice.mqttConfig;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.babyguardianbackend.sensorservice.dao.DeviceRepository;
import org.babyguardianbackend.sensorservice.dao.SensorReadingRepository;
import org.babyguardianbackend.sensorservice.entities.Device;
import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.babyguardianbackend.sensorservice.monitoring.DeviceConnectionMonitor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.mqtt.support.MqttHeaders;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Component
public class MqttInboundHandler {

    private static final Logger log = LoggerFactory.getLogger(MqttInboundHandler.class);
    private final ObjectMapper mapper = new ObjectMapper();

    // TTL internes (tu peux les conserver si utilisés par d'autres services)
    private static final long VITALS_TTL_MS = 15_000;
    private static final long STATUS_TTL_MS = 20_000;

    private final SensorReadingRepository readingRepo;
    private final DeviceRepository deviceRepo;

    private final DeviceConnectionMonitor monitor;

    // queue pour /realtime
    private final BlockingQueue<SensorReading> realtimeQueue = new ArrayBlockingQueue<>(5);

    // État interne (utile si tu as encore un DeviceHealthService qui s’en sert)
    private final Map<String, String> deviceStatus = new ConcurrentHashMap<>();
    private final Map<String, Long>   lastStatusAt = new ConcurrentHashMap<>();
    private final Map<String, Long>   lastVitalsAt = new ConcurrentHashMap<>();

    public MqttInboundHandler(
            SensorReadingRepository readingRepo,
            DeviceRepository deviceRepo,
            DeviceConnectionMonitor monitor
    ) {
        this.readingRepo = readingRepo;
        this.deviceRepo = deviceRepo;
        this.monitor = monitor;
    }

    @ServiceActivator(inputChannel = "mqttInputChannel")
    public void handle(Message<String> message) {
        final String topic = (String) message.getHeaders().get(MqttHeaders.RECEIVED_TOPIC);
        final String payload = message.getPayload();

        try {
            // 1) Statut de présence (LWT/heartbeat) : app/status/<deviceId>
            if (topic.startsWith("app/status/")) {
                final String deviceId = topic.substring("app/status/".length());
                final String normalized = (payload == null ? "unknown" : payload.trim().toLowerCase());

                // Mémorisation locale (si réutilisée ailleurs)
                deviceStatus.put(deviceId, normalized);
                lastStatusAt.put(deviceId, System.currentTimeMillis());

                // Monitoring immédiat
                if ("online".equals(normalized)) {
                    monitor.markConnected(deviceId);
                } else if ("offline".equals(normalized)) {
                    monitor.markDisconnected(deviceId);
                }
                log.info("Status MQTT: {} -> {}", deviceId, normalized);
                return;
            }

            // 2) Mesures vitales : iot/vitals[/<deviceId>]
            if (topic.startsWith("iot/vitals")) {
                final JsonNode j = mapper.readTree(payload);

                // Résoudre deviceId + mac AVANT lambdas → variables "effectivement finales"
                String candidateId = j.hasNonNull("deviceId") ? j.get("deviceId").asText() : null;
                if (candidateId == null && topic.startsWith("iot/vitals/")) {
                    candidateId = topic.substring("iot/vitals/".length());
                }
                final String deviceIdFinal = candidateId;

                final String macFinal = j.hasNonNull("mac") ? j.get("mac").asText() : null;

                if (deviceIdFinal == null || macFinal == null) {
                    log.warn("Invalid payload: missing deviceId or mac (topic={}, payload={})", topic, payload);
                    return;
                }

                // Upsert device (⚠️ n'utiliser que deviceIdFinal/macFinal dans les lambdas)
                Device device = deviceRepo.findByDeviceId(deviceIdFinal)
                        .map(existing -> {
                            if (!macFinal.equals(existing.getMacAddress())) {
                                existing.setMacAddress(macFinal);
                                deviceRepo.save(existing);
                                log.info("Updated MAC for {} -> {}", deviceIdFinal, macFinal);
                            }
                            return existing;
                        })
                        .orElseGet(() -> {
                            Device d = new Device();
                            d.setDeviceId(deviceIdFinal);
                            d.setMacAddress(macFinal);
                            d = deviceRepo.save(d);
                            log.info("Registered new device {} (MAC={})", deviceIdFinal, macFinal);
                            return d;
                        });

                // Enregistrer la lecture
                SensorReading r = new SensorReading();
                r.setDevice(device);
                if (j.hasNonNull("heartRate"))   r.setHeartRate(j.get("heartRate").asInt());
                if (j.hasNonNull("spo2"))        r.setSpo2(j.get("spo2").asInt());
                if (j.hasNonNull("temp"))        r.setTemp(j.get("temp").asDouble());
                else if (j.hasNonNull("temperature")) r.setTemp(j.get("temperature").asDouble());

                Boolean finger = j.has("finger") && !j.get("finger").isNull()
                        ? j.get("finger").asBoolean()
                        : ((r.getHeartRate() != null && r.getHeartRate() > 0)
                        || (r.getSpo2() != null && r.getSpo2() > 0));
                r.setFinger(finger);

                readingRepo.save(r);
                log.info("Saved reading for {} (HR={}, SpO2={}, Temp={}, Finger={})",
                        deviceIdFinal, r.getHeartRate(), r.getSpo2(), r.getTemp(), r.getFinger());

                // Monitoring : activité détectée → connecté + reset du timeout
                monitor.recordDeviceActivity(deviceIdFinal);

                // État interne (si conservé pour compatibilité)
                long now = System.currentTimeMillis();
                lastVitalsAt.put(deviceIdFinal, now);
                deviceStatus.put(deviceIdFinal, "online");
                lastStatusAt.put(deviceIdFinal, now);

                // Réponse temps réel (/realtime)
                if (!realtimeQueue.offer(r)) {
                    realtimeQueue.poll();
                    realtimeQueue.offer(r);
                }
                return;
            }

            // 3) (Optionnel) autres topics fonctionnels si tu en ajoutes à l’avenir
            // ex: app/alerts/<deviceId> ...

        } catch (Exception e) {
            log.error("Failed to process MQTT message (topic={}, payload={})", topic, payload, e);
        }
    }

    /** Lecture temps réel avec timeout (utilisée par /api/sensors/realtime/{deviceId}) */
    public SensorReading waitForRealtimeReading(long timeout, TimeUnit unit) throws InterruptedException {
        return realtimeQueue.poll(timeout, unit);
    }

    /** Statut dérivé (si tu l'utilises encore ailleurs) */
    public String getStatus(String deviceId) {
        long now = System.currentTimeMillis();

        Long vitalsAt = lastVitalsAt.get(deviceId);
        if (vitalsAt != null && (now - vitalsAt) <= VITALS_TTL_MS) return "ONLINE";

        String status = deviceStatus.get(deviceId);
        Long statusAt = lastStatusAt.get(deviceId);
        if (status != null && statusAt != null && (now - statusAt) <= STATUS_TTL_MS) {
            if ("online".equalsIgnoreCase(status))  return "ONLINE";
            if ("offline".equalsIgnoreCase(status)) return "OFFLINE";
        }
        if (vitalsAt != null && (now - vitalsAt) > VITALS_TTL_MS) return "OFFLINE";
        return "unknown";
    }
}
