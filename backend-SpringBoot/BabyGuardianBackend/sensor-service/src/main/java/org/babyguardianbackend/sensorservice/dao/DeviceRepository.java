package org.babyguardianbackend.sensorservice.dao;

import org.babyguardianbackend.sensorservice.entities.Device;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.Set;
import java.util.UUID;

public interface DeviceRepository extends JpaRepository<Device, UUID> {
    Optional<Device> findByDeviceId(String deviceId);
    Optional<Device> findByMacAddress(String macAddress);
    /** Trouver un device par son deviceId (ex: "esp32-...") */

    /** Retourner uniquement les deviceId appartenant à un owner */
    @Query("select d.deviceId from Device d where d.ownerUserId = :ownerUserId")
    Set<String> findDeviceIdsByOwnerUserId(@Param("ownerUserId") String ownerUserId);

}
