package org.babyguardianbackend.sensorservice.mqttConfig;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.babyguardianbackend.sensorservice.dao.DeviceRepository;
import org.babyguardianbackend.sensorservice.dao.SensorReadingRepository;
import org.babyguardianbackend.sensorservice.entities.Device;
import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.babyguardianbackend.sensorservice.monitoring.DeviceConnectionMonitor;
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

        // si un waiter existait déjà (rare), on le remplace proprement
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
            // retire seulement si c’est encore le même future
            realtimeWaiters.remove(id, fut);
        }
    }

    @ServiceActivator(inputChannel = "mqttInputChannel")
    public void handle(Message<?> msg) {
        String topic = (String) msg.getHeaders().get(MqttHeaders.RECEIVED_TOPIC);
        String payload = String.valueOf(msg.getPayload());
        if (topic == null) return;

        try {
            if (topic.startsWith("iot/status/")) {
                handleStatus(topic, payload);
                return;
            }

            if (topic.startsWith("iot/vitals/")) {
                // realtime si topic contient /realtime
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
        String deviceId = extractDeviceId(topic);
        if (deviceId == null) return;
        deviceId = norm(deviceId);

        Device device = upsertDevice(deviceId);

        JsonNode j = om.readTree(payload);

        Integer hr = readInt(j, "heartRate");
        Integer spo2 = readInt(j, "spo2");

        Double temp = readDouble(j, "temp");
        if (temp == null) temp = readDouble(j, "temperature");

        Boolean finger = readBool(j, "finger");

        SensorReading r = new SensorReading();
        r.setDevice(device);
        r.setHeartRate(hr);
        r.setSpo2(spo2);
        r.setTemp(temp);
        r.setFinger(finger);

        SensorReading saved = readingRepo.save(r);

        // activity => connecté
        monitor.recordDeviceActivity(deviceId);

        // realtime si topic /realtime OU payload realtime=true
        boolean payloadRealtime = j.has("realtime") && j.get("realtime").asBoolean(false);
        boolean realtime = topicRealtime || payloadRealtime;

        if (realtime) {
            CompletableFuture<SensorReading> fut = realtimeWaiters.get(deviceId);
            if (fut != null && !fut.isDone()) fut.complete(saved);
        }

        log.debug("[MQTT] vitals {} realtime={} hr={} spo2={} temp={}", deviceId, realtime, hr, spo2, temp);
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

    private Integer readInt(JsonNode j, String k) {
        JsonNode n = j.get(k);
        return (n == null || n.isNull()) ? null : n.asInt();
    }

    private Double readDouble(JsonNode j, String k) {
        JsonNode n = j.get(k);
        return (n == null || n.isNull()) ? null : n.asDouble();
    }

    private Boolean readBool(JsonNode j, String k) {
        JsonNode n = j.get(k);
        return (n == null || n.isNull()) ? null : n.asBoolean();
    }
}

