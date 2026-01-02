package org.babyguardianbackend.authentificationservice.core;

public class EmailAlreadyUsedException extends RuntimeException {
    public EmailAlreadyUsedException() { super("Email already in use"); }
}