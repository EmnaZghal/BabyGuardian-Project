package com.example.profileservice.dto;


import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;

public record BindDeviceRequest(
        @JsonProperty("deviceId")
        @JsonAlias({"device_id", "deviceId"})
        String deviceId
        ) {}
