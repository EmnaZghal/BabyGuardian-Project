package com.example.profileservice.dto;


import java.time.LocalDate;

public record CreateBabyRequest(
        String firstName,
        Integer gender,              // 0/1
        LocalDate birthDate,
        Double gestationalAgeWeeks,
        Double weightKg
) {}

