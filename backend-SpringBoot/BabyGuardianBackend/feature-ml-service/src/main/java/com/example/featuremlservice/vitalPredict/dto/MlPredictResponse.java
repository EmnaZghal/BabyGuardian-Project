package com.example.featuremlservice.vitalPredict.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;


@JsonIgnoreProperties(ignoreUnknown = true)
public record MlPredictResponse(
        @JsonProperty("ok") boolean ok,
        @JsonProperty("deviceId") String deviceId,
        @JsonProperty("pred") Pred pred,
        @JsonProperty("error") String error,
        @JsonProperty("missing") java.util.List<String> missing
) {
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Pred(
            @JsonProperty("temp_1h") Double temp1h,
            @JsonProperty("spo2_1h") Double spo21h,
            @JsonProperty("hr_1h") Double hr1h
    ) {}
}
