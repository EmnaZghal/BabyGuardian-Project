// src/main/java/org/babyguardianbackend/sensorservice/monitoring/DeviceConnectionMonitor.java
package org.babyguardianbackend.sensorservice.monitoring;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Slf4j
@Component
public class DeviceConnectionMonitor {

    // Timeout configurable (en secondes)
    @Value("${monitoring.device-timeout-seconds:30}")
    private long deviceTimeoutSeconds;

    // Suivi lastSeen + état
    private final Map<String, DeviceStatus> devices = new ConcurrentHashMap<>();

    // Abonnés SSE (frontend)
    private final CopyOnWriteArrayList<SseEmitter> alertEmitters = new CopyOnWriteArrayList<>();

    private static class DeviceStatus {
        final String deviceId;
        volatile LocalDateTime lastSeen;
        volatile boolean connected;

        DeviceStatus(String deviceId) {
            this.deviceId = deviceId;
            this.lastSeen = LocalDateTime.now();
            this.connected = true;
        }
    }

    /** Appelé quand on reçoit des vitals/online : rafraîchit lastSeen et (re)connecte si besoin */
    public void recordDeviceActivity(String deviceId) {
        DeviceStatus prev = devices.get(deviceId);
        boolean wasDisconnected = (prev == null || !prev.connected);

        DeviceStatus now = devices.computeIfAbsent(deviceId, DeviceStatus::new);
        now.lastSeen = LocalDateTime.now();
        now.connected = true;

        if (wasDisconnected) {
            log.info("✅ Device {} RECONNECTÉ", deviceId);
            sendConnectionAlert(deviceId, true);
        }
    }

    /** Forçage d’état (utile quand on reçoit LWT “offline”) */
    public void markDisconnected(String deviceId) {
        DeviceStatus st = devices.computeIfAbsent(deviceId, DeviceStatus::new);
        st.connected = false;
        log.warn("❌ Device {} DÉCONNECTÉ (LWT/offline)", deviceId);
        sendConnectionAlert(deviceId, false);
    }

    public void markConnected(String deviceId) {
        recordDeviceActivity(deviceId);
    }

    /** Vérif périodique par timeout (si plus de vitals depuis X sec) */
    @Scheduled(fixedRate = 5000)
    public void checkTimeouts() {
        LocalDateTime now = LocalDateTime.now();
        devices.forEach((id, st) -> {
            long delta = Duration.between(st.lastSeen, now).getSeconds();
            if (st.connected && delta > deviceTimeoutSeconds) {
                st.connected = false;
                log.warn("❌ Device {} DÉCONNECTÉ (timeout > {}s)", id, deviceTimeoutSeconds);
                sendConnectionAlert(id, false);
            }
        });
    }

    /** (Optionnel) keep-alive SSE pour éviter la coupure proxy */
    @Scheduled(fixedRate = 20000)
    public void pingSseClients() {
        broadcast("ping", "{\"type\":\"PING\"}");
    }

    /** Gestion des SSE clients */
    public void addAlertEmitter(SseEmitter emitter) {
        alertEmitters.add(emitter);

        emitter.onCompletion(() -> alertEmitters.remove(emitter));
        emitter.onTimeout(() -> alertEmitters.remove(emitter));
        emitter.onError(e -> alertEmitters.remove(emitter));

        log.info("➕ Client SSE alertes : {} abonnés", alertEmitters.size());

        // Envoi de l’état initial de chaque device
        devices.forEach((deviceId, st) -> {
            String init = String.format(
                    "{\"type\":\"INITIAL_STATUS\",\"deviceId\":\"%s\",\"connected\":%b}",
                    deviceId, st.connected
            );
            safeSend(emitter, "initial-status", init);
        });
    }

    /** Exposé aux controllers */
    public Map<String, Boolean> getAllStatuses() {
        Map<String, Boolean> out = new ConcurrentHashMap<>();
        devices.forEach((id, st) -> out.put(id, st.connected));
        return out;
    }

    public boolean isConnected(String deviceId) {
        DeviceStatus st = devices.get(deviceId);
        return st != null && st.connected;
    }

    /* ======== Internes ======== */

    private void sendConnectionAlert(String deviceId, boolean connected) {
        String json = String.format(
                "{\"type\":\"CONNECTION_STATUS\",\"deviceId\":\"%s\",\"connected\":%b,\"timestamp\":\"%s\"}",
                deviceId, connected, LocalDateTime.now()
        );
        broadcast(connected ? "device-connected" : "device-disconnected", json);
    }

    private void broadcast(String event, String data) {
        alertEmitters.removeIf(em -> {
            if (!safeSend(em, event, data)) {
                try { em.complete(); } catch (Exception ignore) {}
                return true; // retire l'émetteur cassé
            }
            return false;
        });
    }

    private boolean safeSend(SseEmitter em, String event, String data) {
        try {
            em.send(SseEmitter.event().name(event).data(data));
            return true;
        } catch (IOException io) {
            // client fermé / socket reset : bruit normal → DEBUG
            log.debug("SSE write failed (client closed): {}", io.getMessage());
            return false;
        } catch (Exception e) {
            // autre erreur inattendue : on la log en WARN, puis on retire l'émetteur
            log.warn("SSE send error: {}", e.toString());
            return false;
        }
    }
}
