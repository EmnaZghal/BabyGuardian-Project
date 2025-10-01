package org.babyguardianbackend.sensorservice.dao;

import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface SensorReadingRepository extends JpaRepository<SensorReading, UUID> {

    // lookup par device.deviceId (string : esp32-<MAC>)
    Optional<SensorReading> findFirstByDevice_DeviceIdOrderByCreatedAtDesc(String deviceId);
}
