package org.babyguardianbackend.sensorservice.controller;

import lombok.RequiredArgsConstructor;
import org.babyguardianbackend.sensorservice.service.VitalsProducer;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class TestKafka {
//    private final VitalsProducer vitalsProducer;
//    @PostMapping("/publish")
//    public String publish(@RequestParam String topic, @RequestBody String payload) {
//    vitalsProducer.sendCleanVitals("test",topic, payload);
//    return "ok";
//    }
}
