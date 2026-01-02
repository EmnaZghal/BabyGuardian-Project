package org.babyguardianbackend.sensorservice.mqttConfig;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.babyguardianbackend.sensorservice.dao.DeviceRepository;
import org.babyguardianbackend.sensorservice.dao.SensorReadingRepository;
import org.babyguardianbackend.sensorservice.entities.Device;
import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.babyguardianbackend.sensorservice.monitoring.DeviceConnectionMonitor;
import org.babyguardianbackend.sensorservice.service.DeviceOwnershipService;
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

    // TTL internes (pour statut dérivé)
    private static final long VITALS_TTL_MS = 15_000;
    private static final long STATUS_TTL_MS = 20_000;

    private final SensorReadingRepository readingRepo;
    private final DeviceRepository deviceRepo;
    private final DeviceConnectionMonitor monitor;
    private final DeviceOwnershipService ownershipService;

    // queue pour lecture temps réel
    private final BlockingQueue<SensorReading> realtimeQueue = new ArrayBlockingQueue<>(5);

    // caches statut
    private final Map<String, String> deviceStatus = new ConcurrentHashMap<>();
    private final Map<String, Long>   lastStatusAt = new ConcurrentHashMap<>();
    private final Map<String, Long>   lastVitalsAt = new ConcurrentHashMap<>();

    public MqttInboundHandler(
            SensorReadingRepository readingRepo,
            DeviceRepository deviceRepo,
            DeviceConnectionMonitor monitor,
            DeviceOwnershipService ownershipService
    ) {
        this.readingRepo = readingRepo;
        this.deviceRepo = deviceRepo;
        this.monitor = monitor;
        this.ownershipService = ownershipService;
    }

    @ServiceActivator(inputChannel = "mqttInputChannel")
    public void handle(Message<String> message) {
        final String topic = (String) message.getHeaders().get(MqttHeaders.RECEIVED_TOPIC);
        final String payload = message.getPayload();

        try {
            // 0) Sync proprietaire : app/owner/<deviceId>
            if (topic.startsWith("app/owner/")) {
                final String deviceId = topic.substring("app/owner/".length());

                if (payload == null || payload.isBlank()) {
                    ownershipService.setOwnerFromDevice(deviceId, null);
                    log.info("Owner cleared by device for {}", deviceId);
                    return;
                }

                JsonNode node = mapper.readTree(payload);
                String owner = node.hasNonNull("ownerUserId") ? node.get("ownerUserId").asText() : null;
                ownershipService.setOwnerFromDevice(deviceId, owner);
                log.info("Owner set by device for {} -> {}", deviceId, owner);
                return;
            }

            // 1) Statut presence : app/status/<deviceId>
            if (topic.startsWith("app/status/")) {
                final String deviceId = topic.substring("app/status/".length());
                final String normalized = (payload == null ? "unknown" : payload.trim().toLowerCase());

                deviceStatus.put(deviceId, normalized);
                lastStatusAt.put(deviceId, System.currentTimeMillis());

                if ("online".equals(normalized)) {
                    monitor.markConnected(deviceId);
                } else if ("offline".equals(normalized)) {
                    monitor.markDisconnected(deviceId);
                }
                log.info("Status MQTT: {} -> {}", deviceId, normalized);
                return;
            }

            // 2) Mesures vitales : OBLIGATOIREMENT iot/vitals/<deviceId>
            if (topic.startsWith("iot/vitals/")) {
                final String topicDeviceId = topic.substring("iot/vitals/".length()).trim();
                if (topicDeviceId.isBlank()) {
                    log.warn("Invalid topic: missing deviceId in {}", topic);
                    return;
                }

                final JsonNode j = mapper.readTree(payload);

                // 2.1 deviceId JSON obligatoire + doit matcher celui du topic
                if (!j.hasNonNull("deviceId")) {
                    log.warn("Invalid payload: missing deviceId (topic={}, payload={})", topic, payload);
                    return;
                }
                final String jsonDeviceId = j.get("deviceId").asText().trim();
                if (jsonDeviceId.isBlank() || !jsonDeviceId.equals(topicDeviceId)) {
                    log.warn("DeviceId mismatch: topic='{}' vs json='{}' (payload={})",
                            topicDeviceId, jsonDeviceId, payload);
                    return;
                }

                // 2.2 MAC obligatoire et non vide
                if (!j.hasNonNull("mac")) {
                    log.warn("Invalid payload: missing mac (topic={}, payload={})", topic, payload);
                    return;
                }
                final String mac = j.get("mac").asText().trim();
                if (mac.isBlank()) {
                    log.warn("Invalid payload: empty mac (topic={}, payload={})", topic, payload);
                    return;
                }

                // 2.3 Upsert device (maj MAC si change)
                Device device = deviceRepo.findByDeviceId(jsonDeviceId)
                        .map(existing -> {
                            if (!mac.equals(existing.getMacAddress())) {
                                existing.setMacAddress(mac);
                                deviceRepo.save(existing);
                                log.info("Updated MAC for {} -> {}", jsonDeviceId, mac);
                            }
                            return existing;
                        })
                        .orElseGet(() -> {
                            Device d = new Device();
                            d.setDeviceId(jsonDeviceId);
                            d.setMacAddress(mac); // NOT NULL (contrainte)
                            d = deviceRepo.save(d);
                            log.info("Registered new device {} (MAC={})", jsonDeviceId, mac);
                            return d;
                        });

                // 2.4 Lecture capteurs
                SensorReading r = new SensorReading();
                r.setDevice(device);

                if (j.hasNonNull("heartRate"))   r.setHeartRate(j.get("heartRate").asInt());
                if (j.hasNonNull("spo2"))        r.setSpo2(j.get("spo2").asInt());
                if (j.hasNonNull("temp"))        r.setTemp(j.get("temp").asDouble());
                else if (j.hasNonNull("temperature")) r.setTemp(j.get("temperature").asDouble());

                Boolean finger = null;
                if (j.has("finger") && !j.get("finger").isNull()) {
                    finger = j.get("finger").asBoolean();
                } else if (j.has("fingerDetected") && !j.get("fingerDetected").isNull()) {
                    finger = j.get("fingerDetected").asBoolean();
                } else {
                    // fallback heuristique
                    finger = ((r.getHeartRate() != null && r.getHeartRate() > 0)
                            || (r.getSpo2() != null && r.getSpo2() > 0));
                }
                r.setFinger(finger);

                readingRepo.save(r);
                log.info("Saved reading for {} (HR={}, SpO2={}, Temp={}, Finger={})",
                        jsonDeviceId, r.getHeartRate(), r.getSpo2(), r.getTemp(), r.getFinger());

                // 2.5 Monitoring & caches statut
                monitor.recordDeviceActivity(jsonDeviceId);
                long now = System.currentTimeMillis();
                lastVitalsAt.put(jsonDeviceId, now);
                deviceStatus.put(jsonDeviceId, "online");
                lastStatusAt.put(jsonDeviceId, now);

                // push dans la queue /realtime
                if (!realtimeQueue.offer(r)) {
                    realtimeQueue.poll();
                    realtimeQueue.offer(r);
                }
                return;
            }

            // 3) autres topics : ignorés volontairement en Solution B (strict)
            // log.debug("Topic ignoré (non pris en charge en mode strict): {}", topic);

        } catch (Exception e) {
            log.error("Failed to process MQTT message (topic={}, payload={})", topic, payload, e);
        }
    }

    /** Lecture temps réel avec timeout (utilisée par /api/sensors/realtime/{deviceId}) */
    public SensorReading waitForRealtimeReading(long timeout, TimeUnit unit) throws InterruptedException {
        return realtimeQueue.poll(timeout, unit);
    }

    /** Statut dérivé pour UI/contrôleurs si utile */
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
