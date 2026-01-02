package org.babyguardianbackend.authentificationservice.api;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SignupRequest(
        @NotBlank @Size(min = 3, max = 80) String fullName,
        @NotBlank @Email String email,
        @NotBlank @Size(min = 6, max = 128) String password
) {}
