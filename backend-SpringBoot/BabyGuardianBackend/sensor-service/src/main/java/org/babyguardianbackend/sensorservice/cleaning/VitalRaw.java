package org.babyguardianbackend.sensorservice.cleaning;

// cleaning/VitalRaw.java
public record VitalRaw(
        String deviceId,
        Double temperature,
        Double spo2,
        Double heartRate,
        Long timestamp
) {}

