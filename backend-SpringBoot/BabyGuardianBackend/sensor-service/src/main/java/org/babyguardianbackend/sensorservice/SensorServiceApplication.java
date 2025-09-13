package org.babyguardianbackend.sensorservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class SensorServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(SensorServiceApplication.class, args);
    }

}
