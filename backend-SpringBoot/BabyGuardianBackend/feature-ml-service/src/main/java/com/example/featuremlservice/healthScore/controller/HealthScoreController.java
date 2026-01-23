package com.example.featuremlservice.healthScore.controller;


import com.example.featuremlservice.healthScore.dto.HourlyHealthScoreRequest;
import com.example.featuremlservice.healthScore.dto.HourlyHealthScoreResponse;
import com.example.featuremlservice.healthScore.services.HourlyHealthScoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/health-score")
@RequiredArgsConstructor
public class HealthScoreController {

    private final HourlyHealthScoreService service;

    @PostMapping("/hourly")
    public HourlyHealthScoreResponse compute(@RequestBody HourlyHealthScoreRequest req) {
        return service.computeHourly(req);
    }
}

