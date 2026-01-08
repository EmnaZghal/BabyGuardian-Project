package com.example.alertservice.rules;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "app.alert")
public class AlertProperties {
    private double tempHigh = 38.0;
    private int spo2Low = 95;
    private int hrLow = 80;
    private int hrHigh = 180;
    private int cooldownSeconds = 30;
}

