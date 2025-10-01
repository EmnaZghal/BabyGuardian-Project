package org.babyguardianbackend.sensorservice.service;

import lombok.RequiredArgsConstructor;
import org.babyguardianbackend.sensorservice.dao.DeviceRepository;
import org.babyguardianbackend.sensorservice.dao.SensorReadingRepository;
import org.babyguardianbackend.sensorservice.entities.Device;
import org.babyguardianbackend.sensorservice.entities.SensorReading;
import org.babyguardianbackend.sensorservice.mqttConfig.MqttInboundHandler;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DeviceHealthService {

    private static final long DATA_FRESH_THRESHOLD_SEC = 30; // 30s

    private final DeviceRepository deviceRepo;
    private final SensorReadingRepository readingRepo;
    private final MqttInboundHandler mqttHandler;

    /** PathVariable = deviceId logique "esp32-<MAC>" */
    public Map<String, Object> checkDeviceConnectionByDeviceId(String deviceId) {
        Map<String, Object> result = new HashMap<>();

        Device device = deviceRepo.findByDeviceId(deviceId).orElse(null);
        if (device == null) {
            result.put("exists", false);
            result.put("connected", false);
            result.put("message", "Device not found for deviceId: " + deviceId);
            return result;
        }

        SensorReading lastReading = readingRepo
                .findFirstByDevice_DeviceIdOrderByCreatedAtDesc(deviceId)
                .orElse(null);

        if (lastReading == null) {
            result.put("exists", true);
            result.put("connected", false);
            result.put("deviceId", deviceId);
            result.put("macAddress", device.getMacAddress());
            result.put("message", "No data received yet");
            result.put("mqttStatus", mqttHandler.getStatus(deviceId));
            return result;
        }

        long seconds = ChronoUnit.SECONDS.between(lastReading.getCreatedAt(), LocalDateTime.now());
        boolean dataFresh = seconds <= DATA_FRESH_THRESHOLD_SEC;

        String mqttStatus = mqttHandler.getStatus(deviceId); // ONLINE | OFFLINE | unknown
        boolean mqttOnline = "ONLINE".equalsIgnoreCase(mqttStatus);

        boolean isConnected = dataFresh && mqttOnline;

        result.put("exists", true);
        result.put("connected", isConnected);
        result.put("deviceId", deviceId);
        result.put("macAddress", device.getMacAddress());
        result.put("lastSeen", lastReading.getCreatedAt());
        result.put("secondsSinceLastReading", seconds);
        result.put("dataFresh", dataFresh);
        result.put("mqttStatus", mqttStatus);
        result.put("lastReading", Map.of(
                "heartRate", lastReading.getHeartRate() == null ? 0 : lastReading.getHeartRate(),
                "spo2", lastReading.getSpo2() == null ? 0 : lastReading.getSpo2(),
                "temperature", lastReading.getTemp() == null ? 0 : lastReading.getTemp(),
                "finger", lastReading.getFinger() != null && lastReading.getFinger()
        ));
        return result;
    }
}
