package org.babyguardianbackend.sensorservice.entities;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "sensor_readings")
@Data
public class SensorReading {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    // Jointure par la STRING devices.device_id (pas l'UUID PK)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "device_id",                 // colonne FK côté sensor_readings (VARCHAR)
            referencedColumnName = "device_id", // colonne cible côté devices (VARCHAR)
            nullable = false
    )
    private Device device;

    private Integer heartRate;
    private Integer spo2;
    private Double temp;
    private Boolean finger;

    @CreationTimestamp
    private LocalDateTime createdAt;
}
