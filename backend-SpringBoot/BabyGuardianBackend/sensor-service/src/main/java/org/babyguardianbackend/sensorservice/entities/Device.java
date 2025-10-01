package org.babyguardianbackend.sensorservice.entities;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "devices")
@Data
public class Device {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    // IMPORTANT : nom explicite pour que @JoinColumn(... referencedColumnName = "device_id") fonctionne
    @Column(name = "device_id", unique = true, nullable = false)
    private String deviceId;  // ex: "esp32-C00AA81F8A3C"

    @Column(name = "mac_address", unique = true, nullable = false)
    private String macAddress;

    @CreationTimestamp
    private LocalDateTime registeredAt;
}
