package com.example.featuremlservice.vitalPredict.services;

import com.example.featuremlservice.vitalPredict.dto.MlPredictResponse;
import com.example.featuremlservice.vitalPredict.dto.PredictFromDbRequest;
import com.example.featuremlservice.vitalPredict.entity.SensorReadingEntity;
import com.example.featuremlservice.vitalPredict.repository.SensorReadingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PredictOrchestratorService {

    private final SensorReadingRepository repo;
    private final FeatureBuilderService featureBuilder;
    private final MlClientService mlClient;

    public Map<String, Object> predictFromDbHour(PredictFromDbRequest req) {

        Instant ts = req.hourTs(); // instant choisi par user
        LocalDateTime tsLdt = LocalDateTime.ofInstant(ts, ZoneOffset.UTC);

        // 60 lignes avant ts
        List<SensorReadingEntity> rows = repo.findLast60Before(req.deviceId(), tsLdt);

        if (rows.size() < 10) { // seuil minimal (à ajuster)
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Not enough data before hourTs. Need at least 10 rows, got " + rows.size()
            );
        }

        // Important : remettre en ASC pour first/last/slope
        rows.sort(Comparator.comparing(SensorReadingEntity::getCreatedAt));

        Map<String, Object> features = featureBuilder.build1hFeatures(
                req.deviceId(),
                req.subjectId(),
                req.hourTs(),
                req.age(),
                req.sexBin(),
                req.heightCm(),
                req.weightKg(),
                rows
        );

        MlPredictResponse ml = mlClient.predict(features);

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("ok", true);
        out.put("deviceId", req.deviceId());
        out.put("ts", req.hourTs().toString());
        out.put("rows_count", rows.size());
        out.put("features", features);
        out.put("pred", ml != null ? ml.pred() : null);
        return out;
    }
}
