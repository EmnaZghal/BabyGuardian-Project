package com.example.profileservice.entity;


import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "device")
@Getter @Setter
public class DeviceEntity {

    @Id
    @Column(name = "device_id", length = 120)
    private String deviceId;

    @Column(name = "created_at")
    private Instant createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = Instant.now();
    }
}
