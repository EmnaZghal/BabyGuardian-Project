package org.babyguardianbackend.gatewayservice.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.stream.Collectors;

@RestController
public class Test {
    @GetMapping("/test")
    @PreAuthorize("hasAuthority('ADMIN')")
    public Mono<String> test() {
        return Mono.just("test");
    }
    @GetMapping("/roles")
    public List<String> getRoles(Authentication authentication) {
        if (authentication instanceof JwtAuthenticationToken jwtAuth) {
            return jwtAuth.getAuthorities().stream()
                    .map(GrantedAuthority::getAuthority)
                    .collect(Collectors.toList());
        } else {
            return List.of("Unknown or not JWT-authenticated");
        }
    }
}
