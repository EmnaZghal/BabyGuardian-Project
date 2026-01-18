package com.example.featuremlservice.healthScore.util;


import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public final class StatsUtil {

    private StatsUtil() {}

    public static double median(List<Double> values) {
        List<Double> s = clean(values);
        if (s.isEmpty()) return Double.NaN;
        int n = s.size();
        if (n % 2 == 1) return s.get(n/2);
        return (s.get(n/2 - 1) + s.get(n/2)) / 2.0;
    }

    public static double percentile(List<Double> values, double p) {
        List<Double> s = clean(values);
        if (s.isEmpty()) return Double.NaN;
        double idx = (p / 100.0) * (s.size() - 1);
        int lo = (int) Math.floor(idx);
        int hi = (int) Math.ceil(idx);
        if (lo == hi) return s.get(lo);
        double w = idx - lo;
        return s.get(lo) * (1 - w) + s.get(hi) * w;
    }

    public static double min(List<Double> values) {
        List<Double> s = clean(values);
        if (s.isEmpty()) return Double.NaN;
        return s.get(0);
    }

    private static List<Double> clean(List<Double> values) {
        List<Double> s = new ArrayList<>();
        for (Double v : values) {
            if (v == null) continue;
            if (Double.isNaN(v) || Double.isInfinite(v)) continue;
            s.add(v);
        }
        Collections.sort(s);
        return s;
    }
}
