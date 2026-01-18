package com.example.featuremlservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class FeatureMlServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(FeatureMlServiceApplication.class, args);
    }

}
