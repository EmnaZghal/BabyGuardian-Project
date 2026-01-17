package com.example.featuremlservice.vitalPredict.repository;

import com.example.featuremlservice.vitalPredict.entity.SensorReadingEntity;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface SensorReadingRepository extends JpaRepository<SensorReadingEntity, UUID> {

    @Query("""
        select r from SensorReadingEntity r
        where r.deviceId = :deviceId
          and r.createdAt < :ts
        order by r.createdAt desc
    """)
    List<SensorReadingEntity> findLastBefore(
            @Param("deviceId") String deviceId,
            @Param("ts") Instant ts,
            Pageable pageable
    );

    default List<SensorReadingEntity> findLast60Before(String deviceId, Instant ts) {
        return findLastBefore(deviceId, ts, PageRequest.of(0, 60));
    }
}
