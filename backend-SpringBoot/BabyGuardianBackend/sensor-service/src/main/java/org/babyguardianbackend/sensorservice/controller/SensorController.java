package org.babyguardianbackend.sensorservice.controller;

import lombok.RequiredArgsConstructor;
import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.babyguardianbackend.sensorservice.mqttConfig.MqttGateway;
import org.babyguardianbackend.sensorservice.mqttConfig.MqttInboundHandler;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping("/api/sensors")
@RequiredArgsConstructor
public class SensorController {

    private final MqttGateway mqttGateway;
    private final MqttInboundHandler inboundHandler;

    @GetMapping("/realtime/{deviceId}")
    public SensorReading getRealtime(@PathVariable String deviceId) throws InterruptedException {
        // 1) Envoie commande au device
        mqttGateway.sendToMqtt("read", "iot/commands/" + deviceId);

        // 2) Attend une réponse max 6s
        SensorReading reading = inboundHandler.waitForRealtimeReading(6, TimeUnit.SECONDS);

        if (reading == null) {
            throw new RuntimeException("Timeout: aucune réponse du device " + deviceId);
        }
        return reading;
    }
}
