package org.babyguardianbackend.sensorservice.controller;

import lombok.RequiredArgsConstructor;
import org.babyguardianbackend.sensorservice.entities.Device;
import org.babyguardianbackend.sensorservice.service.DeviceOwnershipService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/ownership")
@RequiredArgsConstructor
public class DeviceOwnershipController {

    private final DeviceOwnershipService ownershipService;

    public record BindRequest(String deviceId) {}

    @PostMapping("/bind")
    public ResponseEntity<?> bind(@RequestBody BindRequest req,
                                  @AuthenticationPrincipal Jwt jwt) {
        String userId = jwt.getClaimAsString("sub"); // ID unique Keycloak
        Device d = ownershipService.bindDeviceToUser(req.deviceId(), userId);
        return ResponseEntity.ok(Map.of(
                "deviceId", d.getDeviceId(),
                "ownerUserId", d.getOwnerUserId()
        ));
    }

    @PostMapping("/unbind")
    public ResponseEntity<?> unbind(@RequestBody BindRequest req,
                                    @AuthenticationPrincipal Jwt jwt) {
        String userId = jwt.getClaimAsString("sub");
        Device d = ownershipService.unbindDeviceFromUser(req.deviceId(), userId);
        return ResponseEntity.ok(Map.of(
                "deviceId", d.getDeviceId(),
                "ownerUserId", d.getOwnerUserId()
        ));
    }
}
