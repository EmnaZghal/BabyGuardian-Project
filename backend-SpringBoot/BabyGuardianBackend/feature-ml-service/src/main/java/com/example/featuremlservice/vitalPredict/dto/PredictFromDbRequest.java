package com.example.featuremlservice.vitalPredict.dto;


import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.Instant;

public record PredictFromDbRequest(
        @JsonProperty("deviceId") String deviceId,

        @JsonAlias({"hourTs", "hour_ts"})
        Instant hourTs,

        @JsonAlias({"subjectId", "subject_id"})
        Integer subjectId,

        Integer age,

        @JsonAlias({"sexBin", "sex_bin"})
        Integer sexBin,

        @JsonAlias({"heightCm", "height_cm"})
        Integer heightCm,

        @JsonAlias({"weightKg", "weight_kg"})
        Integer weightKg
) {}

