package org.babyguardianbackend.authentificationservice.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Test {
    @GetMapping("/api")
    public String test() {
        return "test";
    }
}
