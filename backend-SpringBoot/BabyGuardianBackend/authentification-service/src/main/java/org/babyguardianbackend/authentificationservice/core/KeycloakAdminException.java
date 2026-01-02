package org.babyguardianbackend.authentificationservice.core;

public class KeycloakAdminException extends RuntimeException {
    private final int status;

    public KeycloakAdminException(int status, String message) {
        super(message);
        this.status = status;
    }

    public int getStatus() {
        return status;
    }
}
