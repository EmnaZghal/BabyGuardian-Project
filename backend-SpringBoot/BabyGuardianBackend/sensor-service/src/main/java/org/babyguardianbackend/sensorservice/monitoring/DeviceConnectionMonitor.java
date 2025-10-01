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
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.function.Predicate;

@Slf4j
@Component
public class DeviceConnectionMonitor {

    @Value("${monitoring.device-timeout-seconds:30}")
    private long deviceTimeoutSeconds;

    private final Map<String, DeviceStatus> devices = new ConcurrentHashMap<>();

    /** Chaque abonné SSE peut être filtré par un predicate sur deviceId */
    private final CopyOnWriteArrayList<Subscriber> subscribers = new CopyOnWriteArrayList<>();

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

    private static class Subscriber {
        final SseEmitter emitter;
        final Predicate<String> acceptsDeviceId; // null => tout accepter

        Subscriber(SseEmitter emitter, Predicate<String> acceptsDeviceId) {
            this.emitter = emitter;
            this.acceptsDeviceId = acceptsDeviceId;
        }

        boolean accepts(String deviceId) {
            return acceptsDeviceId == null || acceptsDeviceId.test(deviceId);
        }
    }

    /* ================== API Monitoring ================== */

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
        } else {
            // ping fonctionnel (optionnel)
            emit(deviceId, "ping", String.format(
                    "{\"type\":\"PING\",\"deviceId\":\"%s\",\"ts\":%d}", deviceId, System.currentTimeMillis()));
        }
    }

    /** Forçage d’état (LWT offline) */
    public void markDisconnected(String deviceId) {
        DeviceStatus st = devices.computeIfAbsent(deviceId, DeviceStatus::new);
        st.connected = false;
        log.warn("❌ Device {} DÉCONNECTÉ (LWT/offline)", deviceId);
        sendConnectionAlert(deviceId, false);
    }

    public void markConnected(String deviceId) {
        recordDeviceActivity(deviceId);
    }

    /** Statuts exposés */
    public Map<String, Boolean> getAllStatuses() {
        Map<String, Boolean> out = new ConcurrentHashMap<>();
        devices.forEach((id, st) -> out.put(id, st.connected));
        return out;
    }

    public boolean isConnected(String deviceId) {
        DeviceStatus st = devices.get(deviceId);
        return st != null && st.connected;
    }

    /* ================== SSE : abonnements ================== */

    /** Abonnement sans filtre (legacy) */
    public void addAlertEmitter(SseEmitter emitter) {
        addAlertEmitter(emitter, (Predicate<String>) null);
    }

    /** Abonnement filtré par Predicate deviceId -> boolean */
    public void addAlertEmitter(SseEmitter emitter, Predicate<String> acceptsDeviceId) {
        Subscriber sub = new Subscriber(emitter, acceptsDeviceId);
        subscribers.add(sub);

        emitter.onCompletion(() -> subscribers.remove(sub));
        emitter.onTimeout(() -> subscribers.remove(sub));
        emitter.onError(e -> subscribers.remove(sub));

        log.info("➕ Client SSE alertes : {} abonnés", subscribers.size());

        // État initial pour les devices autorisés par le filtre
        devices.forEach((deviceId, st) -> {
            if (sub.accepts(deviceId)) {
                String init = String.format(
                        "{\"type\":\"INITIAL_STATUS\",\"deviceId\":\"%s\",\"connected\":%b}",
                        deviceId, st.connected
                );
                safeSend(sub.emitter, "initial-status", init);
            }
        });
    }

    /** Surcharge pour une liste blanche explicite de devices */
    public void addAlertEmitterWhitelisted(SseEmitter emitter, Set<String> allowedDeviceIds) {
        Predicate<String> p = (allowedDeviceIds == null ? null : allowedDeviceIds::contains);
        addAlertEmitter(emitter, p);
    }

    /* ================== Tâches planifiées ================== */

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

    @Scheduled(fixedRate = 20000)
    public void pingSseClients() {
        broadcast("ping", "{\"type\":\"PING_SSE\"}");
    }

    /* ================== Internes ================== */

    private void sendConnectionAlert(String deviceId, boolean connected) {
        String json = String.format(
                "{\"type\":\"CONNECTION_STATUS\",\"deviceId\":\"%s\",\"connected\":%b,\"timestamp\":\"%s\"}",
                deviceId, connected, LocalDateTime.now()
        );
        emit(deviceId, connected ? "device-connected" : "device-disconnected", json);
    }

    /** Émet uniquement aux abonnés qui acceptent ce deviceId */
    private void emit(String deviceId, String event, String data) {
        subscribers.removeIf(sub -> {
            if (!sub.accepts(deviceId)) return false; // on garde l'abonné mais on ne lui envoie pas cet event
            if (!safeSend(sub.emitter, event, data)) {
                try { sub.emitter.complete(); } catch (Exception ignore) {}
                return true; // retire l'émetteur cassé
            }
            return false;
        });
    }

    private void broadcast(String event, String data) {
        subscribers.removeIf(sub -> {
            if (!safeSend(sub.emitter, event, data)) {
                try { sub.emitter.complete(); } catch (Exception ignore) {}
                return true;
            }
            return false;
        });
    }

    private boolean safeSend(SseEmitter em, String event, String data) {
        try {
            em.send(SseEmitter.event().name(event).data(data));
            return true;
        } catch (IOException io) {
            log.debug("SSE write failed (client closed): {}", io.getMessage());
            return false;
        } catch (Exception e) {
            log.warn("SSE send error: {}", e.toString());
            return false;
        }
    }
}
