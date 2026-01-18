package com.example.featuremlservice.healthScore.services;


import com.example.featuremlservice.healthScore.dto.HourlyHealthScoreRequest;
import com.example.featuremlservice.healthScore.dto.HourlyHealthScoreResponse;
import com.example.featuremlservice.healthScore.dto.RiskPredictResponse;
import com.example.featuremlservice.healthScore.util.StatsUtil;
import com.example.featuremlservice.vitalPredict.entity.SensorReadingEntity;
import com.example.featuremlservice.vitalPredict.repository.SensorReadingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HourlyHealthScoreService {

    private final SensorReadingRepository sensorRepo;
    private final RiskScoreClientService riskClient;

    public HourlyHealthScoreResponse computeHourly(HourlyHealthScoreRequest req) {
        Instant to = req.hourEnd();
        Instant from = to.minus(1, ChronoUnit.HOURS);

        // ⚠️ utilise ta méthode dérivée correcte ici:
        List<SensorReadingEntity> readings =
                sensorRepo.findByDeviceIdAndCreatedAtGreaterThanEqualAndCreatedAtLessThanOrderByCreatedAtDesc(
                        req.deviceId(), from, to
                );

        if (readings.isEmpty()) {
            return new HourlyHealthScoreResponse(
                    req.deviceId(), req.hourEnd(),
                    "INSUFFICIENT_DATA", 0, "Unknown", 0, 0,
                    java.util.Map.of("validRate", 0.0, "count", 0)
            );
        }

        var temps = readings.stream().map(SensorReadingEntity::getTemp).toList();
        var hrs   = readings.stream().map(SensorReadingEntity::getHeartRate).toList();
        var spo2s = readings.stream().map(SensorReadingEntity::getSpo2).toList();

        double tempMedian = StatsUtil.median(temps);
        double hrMedian   = StatsUtil.median(hrs);
        double spo2P05    = StatsUtil.percentile(spo2s, 5);
        double spo2Min    = StatsUtil.min(spo2s);

        double expected = req.expectedSamples() > 0 ? req.expectedSamples() : 12.0;
        double validRate = Math.min(1.0, readings.size() / expected);

        // payload modèle inchangé
        var payload = new HashMap<String, Object>();
        payload.put("gestational_age_weeks", req.gestationalAgeWeeks());
        payload.put("gender", req.gender());
        payload.put("age_days", req.ageDays());
        payload.put("weight_kg", req.weightKg());
        payload.put("temperature_c", tempMedian);
        payload.put("heart_rate_bpm", hrMedian);
        payload.put("oxygen_saturation", spo2P05);

        RiskPredictResponse pred = riskClient.predict(payload);

        double score = pred.health_score() != null ? pred.health_score() : 0.0;
        double conf  = pred.confidence()   != null ? pred.confidence()   : 0.0;

        int aiReliability = (int) Math.round(100.0 * (0.7 * validRate + 0.3 * conf));

        // garde-fous
        String state = "NORMAL";
        if (validRate < 0.6) state = "INSUFFICIENT_DATA";
        else if (spo2Min < 90) state = "CRITICAL";
        else if (score < 75) state = "WARN";

        var stats = new HashMap<String, Object>();
        stats.put("count", readings.size());
        stats.put("validRate", validRate);
        stats.put("tempMedian", tempMedian);
        stats.put("hrMedian", hrMedian);
        stats.put("spo2P05", spo2P05);
        stats.put("spo2Min", spo2Min);

        return new HourlyHealthScoreResponse(
                req.deviceId(),
                req.hourEnd(),
                state,
                score,
                pred.risk_level(),
                conf,
                aiReliability,
                stats
        );
    }
}
