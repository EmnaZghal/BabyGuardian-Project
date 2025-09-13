package org.babyguardianbackend.authentificationservice.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity
public class Test {
    @Id
    private Long id;
    private String nameAuth;
    private String test2;

    public void setId(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }
}
