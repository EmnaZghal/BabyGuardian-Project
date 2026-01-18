package com.example.profileservice.dto;


import java.util.UUID;

public record MlProfileResponse(
        String deviceId,
        UUID babyId,
        String firstName,
        int gender,
        double gestationalAgeWeeks,
        int ageDays,
        double weightKg
) {}
