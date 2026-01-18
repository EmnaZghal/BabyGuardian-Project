package com.example.profileservice.repository;

import com.example.profileservice.entity.BabyEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BabyRepository extends JpaRepository<BabyEntity, UUID> {

    List<BabyEntity> findByOwner_UserId(String userId);

    Optional<BabyEntity> findByOwner_UserIdAndId(String userId, UUID babyId);

    Optional<BabyEntity> findByDevice_DeviceId(String deviceId);
}
