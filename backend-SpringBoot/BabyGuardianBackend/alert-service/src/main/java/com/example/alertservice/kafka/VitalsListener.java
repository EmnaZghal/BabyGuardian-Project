package com.example.alertservice.kafka;

import com.example.alertservice.dto.VitalCleanDto;
import com.example.alertservice.rules.AlertEvent;
import com.example.alertservice.service.AlertEvaluator;
import com.example.alertservice.websocket.VitalWsHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class VitalsListener {

    private final ObjectMapper om;
    private final AlertEvaluator evaluator;
    private final VitalWsHandler ws;

    private String norm(String s) {
        return s == null ? null : s.trim().toLowerCase();
    }

    // ✅ S’exécute automatiquement quand l'app tourne et qu’un message arrive
    @KafkaListener(topics = "${app.kafka.topic.vitals-cleaned:iot.vitals.cleaned}", groupId = "alert-service")
    public void onVitals(ConsumerRecord<String, String> rec) {
        try {
            VitalCleanDto v = om.readValue(rec.value(), VitalCleanDto.class);

            String deviceId = norm((rec.key() != null && !rec.key().isBlank()) ? rec.key() : v.deviceId());
            if (deviceId == null || deviceId.isBlank()) return;

            // 1) Evaluer les alertes
            for (AlertEvent alert : evaluator.evaluate(v)) {

                // 2) Envoyer l’alerte via WebSocket au device concerné
                String alertJson = om.writeValueAsString(alert);
                ws.sendToDevice(deviceId, alertJson);

                log.info("[ALERT] pushed to ws device={} type={} severity={}",
                        deviceId, alert.type(), alert.severity());
            }

        } catch (Exception e) {
            log.error("Failed to process vitals event: {}", e.getMessage());
        }
    }
}
