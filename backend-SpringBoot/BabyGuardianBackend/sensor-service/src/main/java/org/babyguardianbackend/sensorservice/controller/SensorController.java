package org.babyguardianbackend.sensorservice.controller;

import lombok.RequiredArgsConstructor;
import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.babyguardianbackend.sensorservice.mqttConfig.MqttGateway;
import org.babyguardianbackend.sensorservice.mqttConfig.MqttInboundHandler;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


import java.util.Map;
import java.util.concurrent.TimeUnit;


@RestController
@RequestMapping("/api/sensors")
@RequiredArgsConstructor
public class SensorController {

    private final MqttGateway mqttGateway;
    private final MqttInboundHandler inboundHandler;

    @GetMapping("/realtime/{deviceId}")
    public ResponseEntity<?> getRealtime(@PathVariable String deviceId) throws InterruptedException {

        String id = deviceId.trim().toLowerCase();
        mqttGateway.sendToMqtt("read", "iot/commands/" + id);

        SensorReading reading = inboundHandler.waitForRealtimeReading(id, 6, TimeUnit.SECONDS);

        if (reading == null) {
            return ResponseEntity.status(HttpStatus.GATEWAY_TIMEOUT)
                    .body(Map.of(
                            "message", "Timeout: aucune réponse du device",
                            "deviceId", id
                    ));
        }

        // ⚠️ évite de renvoyer l'entité JPA directement (voir Fix 2)
        return ResponseEntity.ok(SensorReadingDto.from(reading, id));
    }

    public record SensorReadingDto(
            String deviceId,
            Integer heartRate,
            Integer spo2,
            Double temp,
            Boolean finger,
            Object createdAt
    ) {
        static SensorReadingDto from(SensorReading r, String fallbackDeviceId) {
            String devId = fallbackDeviceId;
            try {
                if (r.getDevice() != null && r.getDevice().getDeviceId() != null) {
                    devId = r.getDevice().getDeviceId();
                }
            } catch (Exception ignore) {}
            return new SensorReadingDto(
                    devId,
                    r.getHeartRate(),
                    r.getSpo2(),
                    r.getTemp(),
                    r.getFinger(),
                    r.getCreatedAt()
            );
        }

    }}
