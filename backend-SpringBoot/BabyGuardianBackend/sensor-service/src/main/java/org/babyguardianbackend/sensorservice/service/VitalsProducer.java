package org.babyguardianbackend.sensorservice.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.babyguardianbackend.sensorservice.cleaning.VitalClean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class VitalsProducer {

    private final ObjectMapper om;
    private final KafkaTemplate<String, String> kafka;

    @Value("${app.kafka.topic.vitalsCleaned:iot.vitals.cleaned}")
    private String vitalsCleanedTopic;

    public void sendCleanVitals(String deviceId, VitalClean vitalClean) {
        try {
            String json = om.writeValueAsString(vitalClean);
            kafka.send(vitalsCleanedTopic, deviceId, json); // key=deviceId ✅
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize VitalClean to JSON", e);
        }
    }
}
