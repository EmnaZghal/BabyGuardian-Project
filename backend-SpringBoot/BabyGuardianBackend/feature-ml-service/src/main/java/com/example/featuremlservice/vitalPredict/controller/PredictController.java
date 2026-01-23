package com.example.featuremlservice.vitalPredict.controller;

import com.example.featuremlservice.vitalPredict.dto.PredictFromDbRequest;
import com.example.featuremlservice.vitalPredict.services.MlClientService;
import com.example.featuremlservice.vitalPredict.services.PredictOrchestratorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@Slf4j
public class PredictController {

    private final PredictOrchestratorService orchestrator;
    private final MlClientService mlClient;

    @PostMapping("/predict/hourly")
    public ResponseEntity<?> predictHourly(@RequestBody PredictFromDbRequest req) {
        try {
            Map<String, Object> res = orchestrator.predictFromDbHour(req);
            return ResponseEntity.ok(res);

        } catch (IllegalArgumentException e) {
            log.warn("predictHourly bad request: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of(
                    "ok", false,
                    "error", e.getMessage()
            ));

        } catch (Exception e) {
            // ✅ ICI: la vraie cause du 500
            log.error("predictHourly server error. req={}", req, e);

            return ResponseEntity.internalServerError().body(Map.of(
                    "ok", false,
                    "error", "server_error",
                    "details", e.getMessage()
            ));
        }
    }

    @GetMapping("/health")
    public Map<String, Object> healthCheck() {
        boolean ok = mlClient.healthCheck();
        return Map.of("ok", ok);
    }
}
