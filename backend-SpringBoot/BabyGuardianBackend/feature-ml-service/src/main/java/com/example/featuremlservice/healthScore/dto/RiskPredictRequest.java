package com.example.featuremlservice.healthScore.dto;



public record RiskPredictRequest(
        double gestational_age_weeks,
        int gender,
        int age_days,
        double weight_kg,
        double temperature_c,
        double heart_rate_bpm,
        double oxygen_saturation
) {}

