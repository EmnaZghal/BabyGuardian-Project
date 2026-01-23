package com.example.featuremlservice.healthScore.services;


import com.example.featuremlservice.healthScore.dto.HourlyHealthScoreRequest;
import com.example.featuremlservice.healthScore.dto.HourlyHealthScoreResponse;
import com.example.featuremlservice.healthScore.dto.RiskPredictRequest;
import com.example.featuremlservice.healthScore.dto.RiskPredictResponse;
import com.example.featuremlservice.healthScore.util.StatsUtil;
import com.example.featuremlservice.vitalPredict.entity.SensorReadingEntity;
import com.example.featuremlservice.vitalPredict.repository.SensorReadingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HourlyHealthScoreService {

    private final SensorReadingRepository sensorRepo;
    private final RiskScoreClientService riskClient;

    public HourlyHealthScoreResponse computeHourly(HourlyHealthScoreRequest req) {
         LocalDateTime to = req.hourEnd();

        // ⚠️ utilise ta méthode dérivée correcte ici:
        List<SensorReadingEntity> readings =sensorRepo.findByDeviceIdAndCreatedAtLessThanOrderByCreatedAtDesc(
                req.deviceId(),
                to,
                PageRequest.of(0, 30)
        );

        if (readings.isEmpty()) {
            return new HourlyHealthScoreResponse(
                    req.deviceId(), req.hourEnd(),
                    "INSUFFICIENT_DATA", 0, "Unknown", 0, 0,
                    java.util.Map.of("validRate", 0.0, "count", 0)
            );
        }

        var temps = readings.stream().map(SensorReadingEntity::getTemp).toList();
        var hrs = readings.stream().map(SensorReadingEntity::getHeartRate).map(Integer::doubleValue)  .toList();
        var spo2s = readings.stream().map(SensorReadingEntity::getSpo2).map(Integer::doubleValue)  .toList();

        double tempMedian = StatsUtil.median(temps);
        double hrMedian   = StatsUtil.median(hrs);
        double spo2P05    = StatsUtil.percentile(spo2s, 5);
        double spo2Min    = StatsUtil.min(spo2s);

        double expected = req.expectedSamples() > 0 ? req.expectedSamples() : 12.0;
        double validRate = Math.min(1.0, readings.size() / expected);

        // payload modèle inchangé
        RiskPredictRequest payload = new RiskPredictRequest(
                req.gestationalAgeWeeks(),
                req.gender(),
                req.ageDays(),
                req.weightKg(),
                tempMedian,
                hrMedian,
                spo2P05
        );

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
