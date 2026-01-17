package com.example.featuremlservice.vitalPredict.services;


import com.example.featuremlservice.vitalPredict.entity.SensorReadingEntity;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.*;

@Service
public class FeatureBuilderService {

    @Value("${app.window.expected-per-hour:60}")
    private int expectedPerHour;

    @Value("${app.window.min-required:45}")
    private int minRequired;

    // Si true => 0 est considéré comme "missing"
    @Value("${app.clean.zero-as-missing:true}")
    private boolean zeroAsMissing;

    public Map<String, Object> build1hFeatures(
            String deviceId,
            Integer subjectId,
            Instant hourTs,
            Integer age,
            Integer sexBin,
            Integer heightCm,
            Integer weightKg,
            List<SensorReadingEntity> rows
    ) {
        if (rows == null || rows.isEmpty()) {
            throw new IllegalArgumentException("No data found in this hour window.");
        }

        // Nettoyage: temp/spo2/hr (0 => missing si activé)
        List<Double> temps = new ArrayList<>();
        List<Double> spo2s = new ArrayList<>();
        List<Double> hrs   = new ArrayList<>();

        for (SensorReadingEntity r : rows) {
            Double t = r.getTemp();
            Integer s = r.getSpo2();
            Integer h = r.getHeartRate();

            if (t != null && !(zeroAsMissing && t == 0.0)) temps.add(t);
            if (s != null && !(zeroAsMissing && s == 0))     spo2s.add((double) s);
            if (h != null && !(zeroAsMissing && h == 0))     hrs.add((double) h);
        }

        int validCount = temps.size(); // comme ton python: basé sur temp
        if (validCount < minRequired) {
            throw new IllegalArgumentException("Not enough valid points for 1h features. valid_count_1h=" + validCount);
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("deviceId", deviceId);
        out.put("subject_id", subjectId);
        out.put("hour_ts", hourTs.toString());

        // statiques (si tu les as)
        putIfNotNull(out, "age", age);
        putIfNotNull(out, "sex_bin", sexBin);
        putIfNotNull(out, "height_cm", heightCm);
        putIfNotNull(out, "weight_kg", weightKg);

        // hour_sin / hour_cos
        ZonedDateTime zdt = hourTs.atZone(ZoneOffset.UTC);
        double hour = zdt.getHour() + zdt.getMinute() / 60.0;
        out.put("hour_sin", Math.sin(2 * Math.PI * hour / 24.0));
        out.put("hour_cos", Math.cos(2 * Math.PI * hour / 24.0));

        // quality
        out.put("valid_count_1h", validCount);
        out.put("missing_ratio_1h", Math.max(0.0, 1.0 - (validCount / (double) expectedPerHour)));

        // stats
        addStats(out, "temp", temps);
        addStats(out, "spo2", spo2s);
        addStats(out, "hr", hrs);

        return out;
    }

    private void addStats(Map<String, Object> out, String name, List<Double> v) {
        if (v == null || v.isEmpty()) {
            // si un signal est vide → mets 0 pour éviter "missing features" côté Flask
            out.put(name + "_mean_1h", 0.0);
            out.put(name + "_std_1h", 0.0);
            out.put(name + "_min_1h", 0.0);
            out.put(name + "_max_1h", 0.0);
            out.put(name + "_first_1h", 0.0);
            out.put(name + "_last_1h", 0.0);
            out.put(name + "_slope_1h", 0.0);
            return;
        }

        double mean = v.stream().mapToDouble(x -> x).average().orElse(0.0);
        double std  = sampleStd(v, mean);
        double min  = v.stream().mapToDouble(x -> x).min().orElse(0.0);
        double max  = v.stream().mapToDouble(x -> x).max().orElse(0.0);
        double first = v.get(0);
        double last  = v.get(v.size() - 1);

        out.put(name + "_mean_1h", mean);
        out.put(name + "_std_1h", std);
        out.put(name + "_min_1h", min);
        out.put(name + "_max_1h", max);
        out.put(name + "_first_1h", first);
        out.put(name + "_last_1h", last);
        out.put(name + "_slope_1h", last - first);
    }

    // std type pandas (sample std, ddof=1)
    private double sampleStd(List<Double> v, double mean) {
        int n = v.size();
        if (n <= 1) return 0.0;
        double ss = 0.0;
        for (double x : v) {
            double d = x - mean;
            ss += d * d;
        }
        return Math.sqrt(ss / (n - 1));
    }

    private void putIfNotNull(Map<String, Object> out, String k, Object v) {
        if (v != null) out.put(k, v);
    }
}
