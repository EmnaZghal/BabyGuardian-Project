package com.example.featuremlservice.vitalPredict.services;


import com.example.featuremlservice.vitalPredict.dto.MlPredictResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class MlClientService {

    private final WebClient.Builder webClientBuilder;

    @Value("${app.ml.base-url:http://localhost:5000}")
    private String baseUrl;

    @Value("${app.ml.predict-path:/predict}")
    private String predictPath;

    @Value("${app.ml.health-path:/health}")
    private String healthCheck;

    public MlPredictResponse predict(Map<String, Object> features) {
        return webClientBuilder
                .baseUrl(baseUrl)
                .build()
                .post()
                .uri(predictPath)
                .bodyValue(features) // ⚠️ on envoie flat JSON (pas "features": {...})
                .retrieve()
                .bodyToMono(MlPredictResponse.class)
                .block();
    }

    public boolean healthCheck() {
        try {
            Map<?, ?> json = webClientBuilder
                    .baseUrl(baseUrl)
                    .build()
                    .get()
                    .uri(healthCheck)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();

            Object ok = json != null ? json.get("ok") : null;
            return ok instanceof Boolean && (Boolean) ok;

        } catch (Exception e) {
            return false;
        }
    }
}

