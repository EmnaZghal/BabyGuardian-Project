package org.babyguardianbackend.sensorservice.entities;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "sensor_readings")
@Data
public class SensorReading {

    public static final String DEFAULT_DEVICE_ID = "device-1";

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(nullable = false, updatable = false)
    private UUID id;

    @Column(nullable = false)
    private String deviceId = DEFAULT_DEVICE_ID;

    private Integer heartRate;     // bpm
    private Integer spo2;          // %
    private Double  temp;          // °C (une seule valeur consolidée)
    private Boolean finger;        // <--- présence du doigt

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
