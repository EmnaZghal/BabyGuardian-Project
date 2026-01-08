package com.example.alertservice.config;

import com.example.alertservice.rules.AlertProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties(AlertProperties.class)
public class AlertConfig {}

