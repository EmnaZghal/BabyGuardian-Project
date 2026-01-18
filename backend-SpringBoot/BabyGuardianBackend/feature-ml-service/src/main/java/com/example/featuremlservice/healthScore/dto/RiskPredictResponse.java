package com.example.featuremlservice.healthScore.dto;

import java.util.Map;

public record RiskPredictResponse(
        String risk_level,
        Double confidence,
        Double health_score,
        Map<String, Double> probabilities
) {}

