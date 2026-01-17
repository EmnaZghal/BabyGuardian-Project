package com.example.featuremlservice.vitalPredict.controller;


import com.example.featuremlservice.vitalPredict.dto.PredictFromDbRequest;
import com.example.featuremlservice.vitalPredict.services.MlClientService;
import com.example.featuremlservice.vitalPredict.services.PredictOrchestratorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class PredictController {

    private final PredictOrchestratorService orchestrator;
    private final MlClientService mlClient;

    @PostMapping("/predict/hourly")
    public ResponseEntity<?> predictHourly(@RequestBody PredictFromDbRequest req) {
        try {
            Map<String, Object> res = orchestrator.predictFromDbHour(req);
            return ResponseEntity.ok(res);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("ok", false, "error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("ok", false, "error", "server_error"));
        }
    }

    @GetMapping("/health")
    public Map<String, Object> healthCheck() {
        boolean ok = mlClient.healthCheck();
        return Map.of("ok", ok);
    }

}
