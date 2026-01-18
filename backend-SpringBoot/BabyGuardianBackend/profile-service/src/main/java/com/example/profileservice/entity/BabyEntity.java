package com.example.profileservice.entity;


import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "baby")
@Getter @Setter
public class BabyEntity {

    @Id
    @GeneratedValue
    @Column(name = "baby_id")
    private UUID id;

    @Column(name = "first_name")
    private String firstName;

    // 0=female, 1=male
    @Column(name = "gender")
    private Integer gender;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "gestational_age_weeks")
    private Double gestationalAgeWeeks;

    @Column(name = "weight_kg")
    private Double weightKg;

    // Bébé appartient à un seul user
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private AppUserEntity owner;

    // Un bébé a un seul device, un device ne peut être lié qu'à un bébé (unique = true)
    @OneToOne
    @JoinColumn(name = "device_id", referencedColumnName = "device_id", unique = true)
    private DeviceEntity device;

    @Column(name = "created_at")
    private Instant createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = Instant.now();
    }
}
