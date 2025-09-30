package org.babyguardianbackend.sensorservice.mqttConfig;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger; import org.slf4j.LoggerFactory;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageHeaders;
import org.springframework.stereotype.Component;
import org.springframework.integration.mqtt.support.MqttHeaders;
import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.babyguardianbackend.sensorservice.dao.SensorReadingRepository;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.TimeUnit;
@Component
public class MqttInboundHandler {
    private static final Logger log = LoggerFactory.getLogger(MqttInboundHandler.class);
    private final ObjectMapper mapper = new ObjectMapper();
    private final SensorReadingRepository repo;

    // Queue pour stocker la dernière réponse en temps réel
    private final BlockingQueue<SensorReading> realtimeQueue = new ArrayBlockingQueue<>(1);

    public MqttInboundHandler(SensorReadingRepository repo) { this.repo = repo; }

    @ServiceActivator(inputChannel = "mqttInputChannel")
    public void handle(Message<String> message) {
        String topic = (String) message.getHeaders().get(MqttHeaders.RECEIVED_TOPIC);
        String payload = message.getPayload();

        try {
            JsonNode j = mapper.readTree(payload);
            SensorReading r = new SensorReading();

            if (j.hasNonNull("heartRate")) r.setHeartRate(j.get("heartRate").asInt());
            if (j.hasNonNull("spo2"))      r.setSpo2(j.get("spo2").asInt());

            Double t = null;
            if (j.hasNonNull("temp")) t = j.get("temp").asDouble();
            else if (j.hasNonNull("temperature")) t = j.get("temperature").asDouble();
            r.setTemp(t);

            Boolean finger = j.has("finger") && !j.get("finger").isNull()
                    ? j.get("finger").asBoolean()
                    : ((r.getHeartRate() != null && r.getHeartRate() > 0)
                    || (r.getSpo2() != null && r.getSpo2() > 0));
            r.setFinger(finger);

            repo.save(r);
            log.info("Saved reading (topic={}): {}", topic, payload);

            // 🔥 ajoute la mesure dans la queue si quelqu'un attend du realtime
            realtimeQueue.offer(r);

        } catch (Exception e) {
            log.warn("Failed to process MQTT message (topic={} payload={})", topic, payload, e);
        }
    }

    public SensorReading waitForRealtimeReading(long timeout, TimeUnit unit) throws InterruptedException {
        return realtimeQueue.poll(timeout, unit);
    }
}