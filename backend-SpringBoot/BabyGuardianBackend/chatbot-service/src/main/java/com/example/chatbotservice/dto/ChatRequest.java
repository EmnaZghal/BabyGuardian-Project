package com.example.chatbotservice.dto;



public record ChatRequest(
        String message,
        String babyId,
        String intent // ex: "LAST_ALERT" | "CURRENT_STATUS" | "DEFINE_SPO2" | null
) {}

