package org.babyguardianbackend.authentificationservice.api;

import jakarta.ws.rs.WebApplicationException;
import org.babyguardianbackend.authentificationservice.core.EmailAlreadyUsedException;
import org.babyguardianbackend.authentificationservice.core.KeycloakAdminException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EmailAlreadyUsedException.class)
    public ResponseEntity<?> handleEmailUsed(EmailAlreadyUsedException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(new ApiError(ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<?> handleValidation(MethodArgumentNotValidException ex) {
        var msg = ex.getBindingResult().getFieldErrors().stream()
                .map(fe -> fe.getField() + ": " + fe.getDefaultMessage())
                .findFirst().orElse("Validation error");
        return ResponseEntity.badRequest().body(new ApiError(msg));
    }

    @ExceptionHandler(KeycloakAdminException.class)
    public ResponseEntity<?> handleKeycloakAdmin(KeycloakAdminException ex) {
        // 502 car c’est un appel vers un service externe (Keycloak)
        return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                .body(new ApiError("Keycloak admin error (" + ex.getStatus() + "): " + ex.getMessage()));
    }

    @ExceptionHandler(WebApplicationException.class)
    public ResponseEntity<?> handleJaxRs(WebApplicationException ex) {
        int status = ex.getResponse() != null ? ex.getResponse().getStatus() : 500;
        return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                .body(new ApiError("Keycloak call failed (" + status + "): " + ex.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<?> handleOther(Exception ex) {
        return ResponseEntity.internalServerError().body(new ApiError(ex.getMessage()));
    }
}
