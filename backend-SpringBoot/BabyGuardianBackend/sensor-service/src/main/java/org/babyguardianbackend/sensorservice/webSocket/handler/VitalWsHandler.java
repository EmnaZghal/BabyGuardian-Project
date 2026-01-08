package org.babyguardianbackend.sensorservice.webSocket.handler;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

@Component
public class VitalWsHandler extends TextWebSocketHandler {

    // deviceId -> sessions abonnés
    private final ConcurrentMap<String, Set<WebSocketSession>> subs = new ConcurrentHashMap<>();
    // sessionId -> deviceId (si 1 device par session)
    private final ConcurrentMap<String, String> sessionDevice = new ConcurrentHashMap<>();

    private final ObjectMapper om = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        // rien: pas encore abonné
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        JsonNode j = om.readTree(message.getPayload());
        String action = j.path("action").asText("");

        if ("subscribe".equalsIgnoreCase(action)) {
            String deviceId = j.path("deviceId").asText(null);
            if (deviceId == null || deviceId.isBlank()) return;

            // si la session était abonnée à un ancien device, on nettoie
            String prev = sessionDevice.put(session.getId(), deviceId);
            if (prev != null) removeSub(prev, session);

            // on ajoute l'abonnement
            subs.computeIfAbsent(deviceId, k -> ConcurrentHashMap.newKeySet()).add(session);

            session.sendMessage(new TextMessage("{\"type\":\"subscribed\",\"deviceId\":\"" + deviceId + "\"}"));
        }

        if ("unsubscribe".equalsIgnoreCase(action)) {
            String prev = sessionDevice.remove(session.getId());
            if (prev != null) removeSub(prev, session);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        String prev = sessionDevice.remove(session.getId());
        if (prev != null) removeSub(prev, session);
    }

    private void removeSub(String deviceId, WebSocketSession session) {
        Set<WebSocketSession> set = subs.get(deviceId);
        if (set != null) {
            set.remove(session);
            if (set.isEmpty()) subs.remove(deviceId);
        }
    }

    // Appelée quand tu reçois une mesure (Kafka/MQTT)
    public void sendToDevice(String deviceId, String jsonVitals) {
        Set<WebSocketSession> set = subs.get(deviceId);
        if (set == null) return;

        for (WebSocketSession s : set) {
            if (s.isOpen()) {
                try { s.sendMessage(new TextMessage(jsonVitals)); }
                catch (Exception ignored) {}
            }
        }
    }
}
