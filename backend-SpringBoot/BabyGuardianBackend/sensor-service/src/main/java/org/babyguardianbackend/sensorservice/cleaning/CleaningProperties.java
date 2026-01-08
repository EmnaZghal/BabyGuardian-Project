package org.babyguardianbackend.sensorservice.cleaning;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "app.cleaning")
public class CleaningProperties {

    // correspond à app.cleaning.tempMin etc.
    private double tempMin = 34.0;
    private double tempMax = 42.0;

    private int hrMin = 60;
    private int hrMax = 220;

    private int spo2Min = 70;
    private int spo2Max = 100;

    // REJECT | CLAMP | TEST
    private String mode = "REJECT";
}
