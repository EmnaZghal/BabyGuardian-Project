// src/main/java/org/babyguardianbackend/sensorservice/service/DeviceOwnershipService.java
package org.babyguardianbackend.sensorservice.service;

import lombok.RequiredArgsConstructor;
import org.babyguardianbackend.sensorservice.dao.DeviceRepository;
import org.babyguardianbackend.sensorservice.entities.Device;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.NoSuchElementException;
import java.util.Objects;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Transactional
public class DeviceOwnershipService {

    private final DeviceRepository deviceRepo;

    /* ========= Méthodes attendues par AlertsController ========= */

    /** Liste (Set) des deviceId appartenant à l’utilisateur */
    @Transactional(readOnly = true)
    public Set<String> findDeviceIdsByOwner(String userId) {
        return deviceRepo.findDeviceIdsByOwnerUserId(userId);
    }

    /** true si l’utilisateur est propriétaire du deviceId donné */
    @Transactional(readOnly = true)
    public boolean isOwner(String userId, String deviceId) {
        return deviceRepo.findByDeviceId(deviceId)
                .map(d -> Objects.equals(userId, d.getOwnerUserId()))
                .orElse(false);
    }

    /* ========= Méthodes utilitaires déjà utilisées ailleurs ========= */

    /** L’app (mobile) réclame l’ownership */
    public Device bindDeviceToUser(String deviceId, String userId) {
        Device d = deviceRepo.findByDeviceId(deviceId)
                .orElseThrow(() -> new NoSuchElementException("Device introuvable: " + deviceId));

        String current = d.getOwnerUserId();
        if (current != null && !current.isBlank() && !current.equals(userId)) {
            throw new IllegalStateException("Device déjà attribué à un autre utilisateur");
        }
        d.setOwnerUserId(userId);
        return deviceRepo.save(d);
    }

    /** L’app (mobile) détache l’ownership */
    public Device unbindDeviceFromUser(String deviceId, String userId) {
        Device d = deviceRepo.findByDeviceId(deviceId)
                .orElseThrow(() -> new NoSuchElementException("Device introuvable: " + deviceId));

        if (!Objects.equals(userId, d.getOwnerUserId())) {
            throw new IllegalStateException("Vous n'êtes pas propriétaire de ce device");
        }
        d.setOwnerUserId(null);
        return deviceRepo.save(d);
    }

    /** Synchronisation côté device (topic MQTT app/owner/<deviceId>) */
    public void setOwnerFromDevice(String deviceId, @Nullable String ownerUserId) {
        Device d = deviceRepo.findByDeviceId(deviceId)
                .orElseGet(() -> {
                    Device nd = new Device();
                    nd.setDeviceId(deviceId);
                    return nd;
                });
        d.setOwnerUserId(ownerUserId);
        deviceRepo.save(d);
    }
}
