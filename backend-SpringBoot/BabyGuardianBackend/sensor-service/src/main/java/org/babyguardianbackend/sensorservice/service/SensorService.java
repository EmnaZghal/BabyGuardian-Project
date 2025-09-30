package org.babyguardianbackend.sensorservice.services;

import lombok.RequiredArgsConstructor;
import org.babyguardianbackend.sensorservice.dao.SensorReadingRepository;
import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SensorService {
    final private SensorReadingRepository sensorReadingRepository;

    public SensorReading getLatestReading(String deviceId) {
        return sensorReadingRepository.findTop1ByDeviceIdOrderByCreatedAtDesc(deviceId);
    }

}
