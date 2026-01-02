// src/main/java/org/babyguardianbackend/sensorservice/controller/AlertsController.java
package org.babyguardianbackend.sensorservice.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.babyguardianbackend.sensorservice.monitoring.DeviceConnectionMonitor;
import org.babyguardianbackend.sensorservice.service.DeviceOwnershipService;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

@Slf4j
@RestController
@RequestMapping("/api/alerts")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // OK pour dev
public class AlertsController {

    private final DeviceConnectionMonitor monitor;
    private final DeviceOwnershipService ownershipService; // ✳︎ injecté

    /**
     * SSE filtré :
     * - Si deviceId est fourni => stream uniquement ce device (après contrôle d'ownership)
     * - Sinon => stream tous les devices appartenant à l'utilisateur
     */
    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamAlerts(@RequestParam(name = "deviceId", required = false) String deviceId,
                                   @AuthenticationPrincipal Jwt jwt) {

        final String userId = (jwt != null ? jwt.getClaimAsString("sub") : null);
        if (userId == null || userId.isBlank()) {
            // selon ton sécu, tu peux aussi laisser Spring Security 401 avant d'arriver ici
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "JWT manquant ou invalide");
        }

        // Cas 1: deviceId ciblé => vérifier ownership strict
        if (deviceId != null && !deviceId.isBlank()) {
            boolean ok = ownershipService.isOwner(userId, deviceId); // ✳︎ adapte si ton service diffère
            if (!ok) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Vous n'êtes pas propriétaire de ce device");
            }
            SseEmitter emitter = new SseEmitter(TimeUnit.HOURS.toMillis(1));
            monitor.addAlertEmitter(emitter, id -> id.equals(deviceId));

            try {
                emitter.send(SseEmitter.event()
                        .name("connected")
                        .data("{\"message\":\"SSE prêt\",\"scope\":\"single-device\",\"deviceId\":\"" + deviceId + "\"}"));
            } catch (IOException e) {
                log.error("Erreur envoi message initial SSE", e);
                emitter.completeWithError(e);
            }
            return emitter;
        }

        // Cas 2: pas de deviceId => abonne sur la "whitelist" des devices du user
        Set<String> myDevices = ownershipService.findDeviceIdsByOwner(userId); // ✳︎ adapte si besoin
        if (myDevices == null || myDevices.isEmpty()) {
            // on peut retourner directement un SSE “vide” (ou 204 si tu préfères)
            SseEmitter emitter = new SseEmitter(TimeUnit.MINUTES.toMillis(2));
            try {
                emitter.send(SseEmitter.event()
                        .name("connected")
                        .data("{\"message\":\"Aucun device associé à cet utilisateur\"}"));
                emitter.complete();
            } catch (IOException ignore) {}
            return emitter;
        }

        SseEmitter emitter = new SseEmitter(TimeUnit.HOURS.toMillis(1));
        monitor.addAlertEmitterWhitelisted(emitter, myDevices);

        try {
            emitter.send(SseEmitter.event()
                    .name("connected")
                    .data("{\"message\":\"SSE prêt\",\"scope\":\"my-devices\",\"count\":" + myDevices.size() + "}"));
        } catch (IOException e) {
            log.error("Erreur envoi message initial SSE", e);
            emitter.completeWithError(e);
        }
        return emitter;
    }

    /** Map<deviceId, connected> pour les devices du user */
    @GetMapping("/devices/status")
    public ResponseEntity<Map<String, Boolean>> getStatuses(@AuthenticationPrincipal Jwt jwt) {
        // Option simple : retourner tout (comme avant).
        // Option secure (recommandée) : filtrer par devices du user.
        final String userId = (jwt != null ? jwt.getClaimAsString("sub") : null);
        if (userId == null || userId.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "JWT manquant ou invalide");
        }
        // filtrage minimal côté contrôleur
        Map<String, Boolean> all = monitor.getAllStatuses();
        Set<String> mine = ownershipService.findDeviceIdsByOwner(userId); // ✳︎
        all.keySet().retainAll(mine);
        return ResponseEntity.ok(all);
    }

    /** { deviceId, connected } si device appartient au user */
    @GetMapping("/devices/{deviceId}/status")
    public ResponseEntity<Map<String, Object>> getStatus(@PathVariable String deviceId,
                                                         @AuthenticationPrincipal Jwt jwt) {
        final String userId = (jwt != null ? jwt.getClaimAsString("sub") : null);
        if (userId == null || userId.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "JWT manquant ou invalide");
        }
        if (!ownershipService.isOwner(userId, deviceId)) { // ✳︎
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Vous n'êtes pas propriétaire de ce device");
        }
        boolean connected = monitor.isConnected(deviceId);
        return ResponseEntity.ok(Map.of("deviceId", deviceId, "connected", connected));
    }
}
