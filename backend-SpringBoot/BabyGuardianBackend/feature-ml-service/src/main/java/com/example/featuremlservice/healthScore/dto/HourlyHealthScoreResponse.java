package com.example.featuremlservice.healthScore.dto;



import java.time.Instant;
import java.util.Map;

public record HourlyHealthScoreResponse(
        String deviceId,
        Instant hourEnd,
        String state,          // NORMAL/WARN/CRITICAL/INSUFFICIENT_DATA
        double score,          // 0..100
        String riskLevel,      // Low/Medium/High
        double confidence,     // 0..1
        int aiReliability,     // 0..100
        Map<String, Object> stats
) {}
