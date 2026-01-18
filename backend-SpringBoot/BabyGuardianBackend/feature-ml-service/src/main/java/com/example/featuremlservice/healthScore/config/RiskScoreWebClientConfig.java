package com.example.featuremlservice.healthScore.config;



import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class RiskScoreWebClientConfig {

    @Bean("riskScoreWebClient")
    public WebClient riskScoreWebClient(@Value("${app.ml.riskScoreBaseUrl}") String baseUrl) {
        return WebClient.builder()
                .baseUrl(baseUrl)
                .build();
    }
}

