// src/main/java/org/babyguardianbackend/sensorservice/controller/AlertsController.java
package org.babyguardianbackend.sensorservice.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.babyguardianbackend.sensorservice.monitoring.DeviceConnectionMonitor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Slf4j
@RestController
@RequestMapping("/api/alerts")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // OK pour dev
public class AlertsController {

    private final DeviceConnectionMonitor monitor;

    /** Flux SSE : device-connected / device-disconnected / initial-status / ping */
    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamAlerts() {
        SseEmitter emitter = new SseEmitter(TimeUnit.HOURS.toMillis(1));
        monitor.addAlertEmitter(emitter);

        try {
            emitter.send(SseEmitter.event()
                    .name("connected")
                    .data("{\"message\":\"Connecté au flux d'alertes\"}"));
        } catch (IOException e) {
            log.error("Erreur envoi message initial SSE", e);
            emitter.completeWithError(e);
        }
        return emitter;
    }

    /** Map<deviceId, connected> */
    @GetMapping("/devices/status")
    public ResponseEntity<Map<String, Boolean>> getStatuses() {
        return ResponseEntity.ok(monitor.getAllStatuses());
    }

    /** { deviceId, connected } */
    @GetMapping("/devices/{deviceId}/status")
    public ResponseEntity<Map<String, Object>> getStatus(@PathVariable String deviceId) {
        boolean connected = monitor.isConnected(deviceId);
        return ResponseEntity.ok(Map.of("deviceId", deviceId, "connected", connected));
    }
}
