package org.babyguardianbackend.sensorservice.cleaning;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DataCleaningService {

    private final CleaningProperties p;

    public VitalClean cleanOrThrow(VitalRaw raw, String fallbackDeviceId) {

        String deviceId = (raw.deviceId() != null && !raw.deviceId().isBlank())
                ? raw.deviceId()
                : fallbackDeviceId;

        long ts = (raw.timestamp() != null) ? raw.timestamp() : System.currentTimeMillis();

        if (raw.temperature() == null || raw.spo2() == null || raw.heartRate() == null) {
            throw new IllegalArgumentException("Missing fields");
        }

        double temp = raw.temperature();
        double spo2 = raw.spo2();
        double hr   = raw.heartRate();

        // Fahrenheit -> Celsius (si besoin)
        if (temp > 60) temp = (temp - 32) * (5.0 / 9.0);

        // ✅ MODE TEST : accepte tout (pas de validation)
        if ("TEST".equalsIgnoreCase(p.getMode())) {
            return new VitalClean(
                    deviceId,
                    temp,
                    (int) Math.round(spo2),
                    (int) Math.round(hr),
                    ts,
                    "TEST"
            );
        }

        boolean clamped = false;

        if ("CLAMP".equalsIgnoreCase(p.getMode())) {

            double newTemp = clamp(temp, p.getTempMin(), p.getTempMax());
            double newSpo2 = clamp(spo2, p.getSpo2Min(), p.getSpo2Max());
            double newHr   = clamp(hr,   p.getHrMin(),   p.getHrMax());

            clamped = (newTemp != temp) || (newSpo2 != spo2) || (newHr != hr);

            temp = newTemp;
            spo2 = newSpo2;
            hr = newHr;

        } else { // REJECT
            if (temp < p.getTempMin() || temp > p.getTempMax()) throw new IllegalArgumentException("temp invalid");
            if (spo2 < p.getSpo2Min() || spo2 > p.getSpo2Max()) throw new IllegalArgumentException("spo2 invalid");
            if (hr < p.getHrMin() || hr > p.getHrMax()) throw new IllegalArgumentException("hr invalid");
        }

        return new VitalClean(
                deviceId,
                temp,
                (int) Math.round(spo2),
                (int) Math.round(hr),
                ts,
                clamped ? "CLAMPED" : "OK"
        );
    }

    private double clamp(double v, double min, double max) {
        return Math.max(min, Math.min(max, v));
    }
}
