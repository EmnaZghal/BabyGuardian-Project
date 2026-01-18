package com.example.featuremlservice.healthScore.dto;



import java.time.Instant;

public record HourlyHealthScoreRequest(
        String deviceId,
        Instant hourEnd,             // ex: 2026-01-18T10:00:00Z
        int expectedSamples,         // ex: 12 (si 1 point/5min)
        // profil requis par ton modèle (si tu ne veux pas le chercher ailleurs)
        double gestationalAgeWeeks,
        int gender,
        int ageDays,
        double weightKg
) {}
