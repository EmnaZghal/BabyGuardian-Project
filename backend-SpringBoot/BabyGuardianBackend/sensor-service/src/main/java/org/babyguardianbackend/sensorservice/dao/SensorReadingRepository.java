package org.babyguardianbackend.sensorservice.dao;


import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface SensorReadingRepository extends JpaRepository<SensorReading, UUID> {

    List<SensorReading> findTop50ByDeviceIdOrderByCreatedAtDesc(String deviceId);
    SensorReading findTop1ByDeviceIdOrderByCreatedAtDesc(String deviceId);

}
