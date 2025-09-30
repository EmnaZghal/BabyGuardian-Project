package org.babyguardianbackend.authentificationservice.api;

import org.babyguardianbackend.authentificationservice.core.KeycloakSignupService;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.Map;

@Validated
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final KeycloakSignupService signupService;

    public AuthController(KeycloakSignupService signupService) {
        this.signupService = signupService;
    }

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@Valid @RequestBody SignupRequest req) {
        String userId = signupService.signup(req.fullName(), req.email(), req.password());
        return ResponseEntity.ok(Map.of("userId", userId, "message", "Account created"));
    }
}
