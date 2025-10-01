package org.babyguardianbackend.sensorservice.dao;

import org.babyguardianbackend.sensorservice.entities.Device;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface DeviceRepository extends JpaRepository<Device, UUID> {

    Optional<Device> findByDeviceId(String deviceId);     // esp32-...
    Optional<Device> findByMacAddress(String macAddress); // C00AA81F8A3C (sans :)
}
