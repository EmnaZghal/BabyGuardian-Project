package com.example.alertservice.rules;

public record AlertEvent(
        String deviceId,
        String type,      // HIGH_TEMP | LOW_SPO2 | HIGH_HR | LOW_HR ...
        String severity,  // LOW | MEDIUM | HIGH
        String message,
        double value,
        double threshold,
        long timestamp
) {}

