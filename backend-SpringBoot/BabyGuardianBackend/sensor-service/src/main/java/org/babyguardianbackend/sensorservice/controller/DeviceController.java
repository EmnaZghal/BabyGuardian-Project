package org.babyguardianbackend.sensorservice.controller;

import lombok.RequiredArgsConstructor;
import org.babyguardianbackend.sensorservice.service.DeviceHealthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/devices")
@RequiredArgsConstructor
public class DeviceController {

    private final DeviceHealthService healthService;

    // ex: GET /api/devices/esp32-C00AA81F8A3C/connected
    @GetMapping("/{deviceId}/connected")
    public ResponseEntity<?> isDeviceConnected(@PathVariable String deviceId) {
        return ResponseEntity.ok(healthService.checkDeviceConnectionByDeviceId(deviceId));
    }
}
