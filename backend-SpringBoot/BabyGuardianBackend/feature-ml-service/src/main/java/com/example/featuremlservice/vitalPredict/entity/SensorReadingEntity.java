package com.example.featuremlservice.vitalPredict.entity;


import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
@Entity
@Table(name = "sensor_readings")
public class SensorReadingEntity {

    @Id
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "device_id", nullable = false)
    private String deviceId;

    @Column(name = "temp")
    private Double temp;

    @Column(name = "spo2")
    private Integer spo2;

    @Column(name = "heart_rate")
    private Integer heartRate;

    // colonne "finger" existe mais on n’en a pas besoin => pas mappée, c’est OK.
}
