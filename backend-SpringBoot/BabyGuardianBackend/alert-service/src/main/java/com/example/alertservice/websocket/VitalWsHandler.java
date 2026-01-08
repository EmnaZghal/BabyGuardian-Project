package com.example.alertservice.websocket;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

@Component
@RequiredArgsConstructor
public class VitalWsHandler extends TextWebSocketHandler {

    // deviceId -> sessions abonnés
    private final ConcurrentMap<String, Set<WebSocketSession>> subs = new ConcurrentHashMap<>();
    // sessionId -> deviceId
    private final ConcurrentMap<String, String> sessionDevice = new ConcurrentHashMap<>();

    private final ObjectMapper om;

    private String norm(String s) {
        return s == null ? null : s.trim().toLowerCase();
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        JsonNode j = om.readTree(message.getPayload());
        String action = j.path("action").asText("");

        if ("subscribe".equalsIgnoreCase(action)) {
            String deviceId = norm(j.path("deviceId").asText(null));
            if (deviceId == null || deviceId.isBlank()) return;

            String prev = sessionDevice.put(session.getId(), deviceId);
            if (prev != null) removeSub(prev, session);

            subs.computeIfAbsent(deviceId, k -> ConcurrentHashMap.newKeySet()).add(session);

            session.sendMessage(new TextMessage("{\"type\":\"subscribed\",\"deviceId\":\"" + deviceId + "\"}"));
            return;
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

    // ✅ Envoie un JSON (alert) aux apps abonnées à ce deviceId
    public void sendToDevice(String deviceId, String json) {
        deviceId = norm(deviceId);
        Set<WebSocketSession> set = subs.get(deviceId);
        if (set == null) return;

        for (WebSocketSession s : set) {
            if (s.isOpen()) {
                try { s.sendMessage(new TextMessage(json)); }
                catch (Exception ignored) {}
            }
        }
    }
}
