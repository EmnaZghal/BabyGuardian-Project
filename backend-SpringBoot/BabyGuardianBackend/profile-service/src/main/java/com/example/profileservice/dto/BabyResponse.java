package com.example.profileservice.dto;



import java.time.LocalDate;
import java.util.UUID;

public record BabyResponse(
        UUID id,
        String firstName,
        Integer gender,
        LocalDate birthDate,
        Double gestationalAgeWeeks,
        Double weightKg,
        String deviceId
) {}
