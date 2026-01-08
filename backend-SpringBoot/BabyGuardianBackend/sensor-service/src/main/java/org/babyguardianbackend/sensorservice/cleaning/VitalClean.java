package org.babyguardianbackend.sensorservice.cleaning;

// cleaning/VitalClean.java
public record VitalClean(
        String deviceId,
        double temperatureC,
        int spo2,
        int heartRate,
        long timestamp,
        String quality // OK | CLAMPED
) {}

