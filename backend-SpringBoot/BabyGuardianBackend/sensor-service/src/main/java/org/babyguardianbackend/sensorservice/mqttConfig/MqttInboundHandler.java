package org.babyguardianbackend.sensorservice.mqttConfig;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.babyguardianbackend.sensorservice.cleaning.DataCleaningService;
import org.babyguardianbackend.sensorservice.cleaning.VitalClean;
import org.babyguardianbackend.sensorservice.cleaning.VitalRaw;
import org.babyguardianbackend.sensorservice.dao.DeviceRepository;
import org.babyguardianbackend.sensorservice.dao.SensorReadingRepository;
import org.babyguardianbackend.sensorservice.entities.Device;
import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.babyguardianbackend.sensorservice.monitoring.DeviceConnectionMonitor;
import org.babyguardianbackend.sensorservice.service.VitalsProducer;
import org.babyguardianbackend.sensorservice.webSocket.handler.VitalWsHandler;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.mqtt.support.MqttHeaders;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Component;

import java.util.concurrent.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class MqttInboundHandler {

    private final DeviceRepository deviceRepo;
    private final SensorReadingRepository readingRepo;
    private final DeviceConnectionMonitor monitor;
    private final DataCleaningService cleaningService;
    private final VitalsProducer vitalsProducer;
    private final VitalWsHandler wsHandler;

    private final ObjectMapper om = new ObjectMapper();

    private final ConcurrentMap<String, String> statusByDevice = new ConcurrentHashMap<>();
    private final ConcurrentMap<String, CompletableFuture<SensorReading>> realtimeWaiters = new ConcurrentHashMap<>();

    private String norm(String deviceId) {
        return deviceId == null ? null : deviceId.trim().toLowerCase();
    }

    public String getStatus(String deviceId) {
        return statusByDevice.getOrDefault(norm(deviceId), "unknown");
    }

    public SensorReading waitForRealtimeReading(String deviceId, long timeout, TimeUnit unit) throws InterruptedException {
        String id = norm(deviceId);
        CompletableFuture<SensorReading> fut = new CompletableFuture<>();

        CompletableFuture<SensorReading> prev = realtimeWaiters.put(id, fut);
        if (prev != null && !prev.isDone()) {
            prev.completeExceptionally(new CancellationException("Replaced by a new realtime waiter"));
        }

        try {
            return fut.get(timeout, unit);
        } catch (TimeoutException e) {
            return null;
        } catch (ExecutionException e) {
            log.warn("Realtime waiter error: {}", e.getMessage());
            return null;
        } finally {
            realtimeWaiters.remove(id, fut);
        }
    }

    @ServiceActivator(inputChannel = "mqttInputChannel")
    public void handle(Message<?> msg) {
        String topic = (String) msg.getHeaders().get(MqttHeaders.RECEIVED_TOPIC);
        String payload = String.valueOf(msg.getPayload());
        if (topic == null) return;

        try {
            // Supporte iot/status/* ET app/status/* (au cas où)
            if (topic.startsWith("iot/status/") || topic.startsWith("app/status/")) {
                handleStatus(topic, payload);
                return;
            }

            // Supporte iot/vitals/* ET app/vitals/*
            if (topic.startsWith("iot/vitals/") || topic.startsWith("app/vitals/")) {
                boolean topicRealtime = topic.contains("/realtime");
                handleVitals(topic, payload, topicRealtime);
                return;
            }

            log.debug("MQTT ignored topic={}", topic);
        } catch (Exception e) {
            log.error("MQTT handler error topic={} payload={} err={}", topic, payload, e.toString());
        }
    }

    private void handleStatus(String topic, String payload) {
        String deviceId = extractDeviceId(topic);
        if (deviceId == null) return;
        deviceId = norm(deviceId);

        String st = (payload == null ? "unknown" : payload.trim().toUpperCase());
        statusByDevice.put(deviceId, st);

        if ("ONLINE".equals(st)) monitor.markConnected(deviceId);
        else if ("OFFLINE".equals(st)) monitor.markDisconnected(deviceId);

        log.info("[MQTT] status {} => {}", deviceId, st);
    }

    private void handleVitals(String topic, String payload, boolean topicRealtime) throws Exception {
        String deviceIdFromTopic = extractDeviceId(topic);
        if (deviceIdFromTopic == null) return;
        deviceIdFromTopic = norm(deviceIdFromTopic);

        // dès qu'on reçoit une mesure => activité device (même si on rejette la valeur après)
        monitor.recordDeviceActivity(deviceIdFromTopic);

        JsonNode j = om.readTree(payload);

        // deviceId peut exister dans le JSON, sinon fallback sur topic
        String deviceIdFromPayload = readText(j, "deviceId");
        String effectiveDeviceId = norm((deviceIdFromPayload != null && !deviceIdFromPayload.isBlank())
                ? deviceIdFromPayload
                : deviceIdFromTopic);

        // Récupération flexible des champs (plusieurs clés possibles)
        Double temp = firstDouble(j, "temp", "temperature", "tempC");
        Double spo2 = firstDouble(j, "spo2", "SpO2");
        Double hr   = firstDouble(j, "heartRate", "hr", "bpm");
        Long ts     = firstLong(j, "timestamp", "ts", "time");

        // Nettoyage (REJECT ou CLAMP selon app.cleaning.mode)
        VitalClean clean;
        try {
            VitalRaw raw = new VitalRaw(effectiveDeviceId, temp, spo2, hr, ts);
            clean = cleaningService.cleanOrThrow(raw, effectiveDeviceId);
            // Envoi vers Kafka
            vitalsProducer.sendCleanVitals(deviceIdFromTopic,clean);
            wsHandler.sendToDevice(deviceIdFromTopic, om.writeValueAsString(clean));
        } catch (IllegalArgumentException ex) {
            // mode REJECT => on ignore la mesure
            log.warn("[MQTT] vitals REJECTED device={} reason={} payload={}", effectiveDeviceId, ex.getMessage(), payload);
            return;
        }

        Device device = upsertDevice(effectiveDeviceId);

        Boolean finger = readBool(j, "finger");

        SensorReading r = new SensorReading();
        r.setDevice(device);
        r.setTemp(clean.temperatureC());
        r.setSpo2(clean.spo2());
        r.setHeartRate(clean.heartRate());
        r.setFinger(finger);

        // Si ton entity a un champ timestamp/createdAt, décommente et adapte :
        // r.setTimestamp(clean.timestamp());

        SensorReading saved = readingRepo.save(r);

        boolean payloadRealtime = j.has("realtime") && j.get("realtime").asBoolean(false);
        boolean realtime = topicRealtime || payloadRealtime;

        if (realtime) {
            CompletableFuture<SensorReading> fut = realtimeWaiters.get(effectiveDeviceId);
            if (fut != null && !fut.isDone()) fut.complete(saved);
        }

        log.debug("[MQTT] vitals {} quality={} realtime={} hr={} spo2={} temp={}",
                effectiveDeviceId, clean.quality(), realtime, clean.heartRate(), clean.spo2(), clean.temperatureC());
    }

    private Device upsertDevice(String deviceId) {
        return deviceRepo.findByDeviceId(deviceId)
                .orElseGet(() -> {
                    Device d = new Device();
                    d.setDeviceId(deviceId);
                    d.setMacAddress(macFromDeviceId(deviceId)); // NOT NULL
                    return deviceRepo.save(d);
                });
    }

    private String extractDeviceId(String topic) {
        // iot/vitals/<deviceId>[/realtime]
        // iot/status/<deviceId>
        // app/vitals/<deviceId> ...
        String[] parts = topic.split("/");
        if (parts.length < 3) return null;
        return parts[2];
    }

    private String macFromDeviceId(String deviceId) {
        int idx = deviceId.indexOf("-");
        String hex = (idx >= 0 ? deviceId.substring(idx + 1) : deviceId);
        hex = hex.replace(":", "").trim().toUpperCase();
        if (hex.length() != 12) return hex;

        return hex.substring(0,2)+":"+hex.substring(2,4)+":"+hex.substring(4,6)+":"+
                hex.substring(6,8)+":"+hex.substring(8,10)+":"+hex.substring(10,12);
    }

    // --------- Helpers robustes ---------

    private String readText(JsonNode j, String k) {
        JsonNode n = j.get(k);
        return (n == null || n.isNull()) ? null : n.asText(null);
    }

    private Double firstDouble(JsonNode j, String... keys) {
        for (String k : keys) {
            Double v = readDouble(j, k);
            if (v != null) return v;
        }
        return null;
    }

    private Long firstLong(JsonNode j, String... keys) {
        for (String k : keys) {
            Long v = readLong(j, k);
            if (v != null) return v;
        }
        return null;
    }

    private Double readDouble(JsonNode j, String k) {
        JsonNode n = j.get(k);
        if (n == null || n.isNull()) return null;
        // support nombre OU string "36.7"
        if (n.isNumber()) return n.asDouble();
        if (n.isTextual()) {
            try { return Double.parseDouble(n.asText().trim()); }
            catch (Exception ignored) { return null; }
        }
        return null;
    }

    private Long readLong(JsonNode j, String k) {
        JsonNode n = j.get(k);
        if (n == null || n.isNull()) return null;
        if (n.isNumber()) return n.asLong();
        if (n.isTextual()) {
            try { return Long.parseLong(n.asText().trim()); }
            catch (Exception ignored) { return null; }
        }
        return null;
    }

    private Boolean readBool(JsonNode j, String k) {
        JsonNode n = j.get(k);
        return (n == null || n.isNull()) ? null : n.asBoolean();
    }
}
