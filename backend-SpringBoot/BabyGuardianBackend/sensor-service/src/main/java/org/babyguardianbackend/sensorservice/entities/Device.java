package org.babyguardianbackend.sensorservice.entities;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Entity
@Table(name = "devices",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_devices_device_id", columnNames = "device_id"),
                @UniqueConstraint(name = "uk_devices_mac",       columnNames = "mac_address")
        })
public class Device {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "device_id", nullable = false, length = 100)
    private String deviceId;

    @Column(name = "mac_address", nullable = false, length = 64)
    private String macAddress;

    // Hibernate gère la version. Type wrapper pour éviter les NPE internes.
    @Version
    @Column(name = "version", nullable = false)
    private Long version = 0L;


    @Column(name = "owner_user_id")
    private String ownerUserId;

    @CreationTimestamp
    private LocalDateTime registeredAt;


}
