package com.example.alertservice.service;

import com.example.alertservice.rules.AlertEvent;
import com.example.alertservice.rules.AlertProperties;
import com.example.alertservice.dto.VitalCleanDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class AlertEvaluator {

    private final AlertProperties p;

    // anti-spam: (deviceId|type) -> lastTimestampMillis
    private final Map<String, Long> lastSent = new ConcurrentHashMap<>();

    public List<AlertEvent> evaluate(VitalCleanDto v) {
        List<AlertEvent> out = new ArrayList<>();

        // Exemple règles (placeholder)
        if (v.temperatureC() >= p.getTempHigh()) {
            addIfNotInCooldown(out, v, "HIGH_TEMP", "HIGH",
                    "Temperature above threshold", v.temperatureC(), p.getTempHigh());
        }
        if (v.spo2() <= p.getSpo2Low()) {
            addIfNotInCooldown(out, v, "LOW_SPO2", "HIGH",
                    "SpO2 below threshold", v.spo2(), p.getSpo2Low());
        }
        if (v.heartRate() >= p.getHrHigh()) {
            addIfNotInCooldown(out, v, "HIGH_HR", "MEDIUM",
                    "Heart rate above threshold", v.heartRate(), p.getHrHigh());
        }
        if (v.heartRate() <= p.getHrLow()) {
            addIfNotInCooldown(out, v, "LOW_HR", "MEDIUM",
                    "Heart rate below threshold", v.heartRate(), p.getHrLow());
        }

        return out;
    }

    private void addIfNotInCooldown(List<AlertEvent> out, VitalCleanDto v,
                                    String type, String severity,
                                    String msg, double value, double threshold) {
        String key = v.deviceId() + "|" + type;
        long now = System.currentTimeMillis();
        long cooldownMs = p.getCooldownSeconds() * 1000L;

        Long prev = lastSent.get(key);
        if (prev != null && (now - prev) < cooldownMs) return;

        lastSent.put(key, now);
        out.add(new AlertEvent(v.deviceId(), type, severity, msg, value, threshold, v.timestamp()));
    }
}
