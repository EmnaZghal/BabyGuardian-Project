package com.example.featuremlservice.healthScore.config;




import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
@RequiredArgsConstructor
public class RiskScoreWebClientConfig {

    private final WebClient.Builder webClientBuilder;

    @Bean("riskScoreWebClient")
    public WebClient riskScoreWebClient(@Value("${app.ml.riskScoreBaseUrl}") String baseUrl) {
        return webClientBuilder
                .baseUrl(baseUrl)
                .build();
    }
}


