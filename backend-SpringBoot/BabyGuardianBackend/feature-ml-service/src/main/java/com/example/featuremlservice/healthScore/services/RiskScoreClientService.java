package com.example.featuremlservice.healthScore.services;




import com.example.featuremlservice.healthScore.dto.RiskPredictRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;


@Service
@RequiredArgsConstructor
public class RiskScoreClientService {

    @Qualifier("riskScoreWebClient")
    private final WebClient web;

    public RiskPredictRequest predict(Object payload) {
        return web.post()
                .uri("/predict")
                .bodyValue(payload)
                .retrieve()
                .bodyToMono(RiskPredictRequest.class)
                .block();
    }
}
