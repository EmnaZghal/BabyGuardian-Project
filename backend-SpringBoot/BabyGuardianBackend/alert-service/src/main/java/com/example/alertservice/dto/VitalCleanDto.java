package com.example.alertservice.dto;

public record VitalCleanDto(
        String deviceId,
        double temperatureC,
        int spo2,
        int heartRate,
        long timestamp,
        String quality
) {}

