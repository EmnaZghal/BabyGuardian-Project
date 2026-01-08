package org.babyguardianbackend.sensorservice.webSocket.webSocketConfig;

import org.babyguardianbackend.sensorservice.webSocket.handler.VitalWsHandler;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final VitalWsHandler handler;

    public WebSocketConfig(VitalWsHandler handler) {
        this.handler = handler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(handler, "/ws/vitals")
                .setAllowedOrigins("*"); // en prod: mets ton domaine
    }
}

