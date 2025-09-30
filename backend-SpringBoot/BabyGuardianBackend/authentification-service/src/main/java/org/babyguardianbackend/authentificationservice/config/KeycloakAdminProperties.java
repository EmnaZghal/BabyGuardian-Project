package org.babyguardianbackend.authentificationservice.config;


import lombok.Getter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Configuration
@ConfigurationProperties(prefix = "keycloak")
public class KeycloakAdminProperties {

    private String serverUrl;
    private String realm;

    private final Admin admin = new Admin();

    public static class Admin {
        private String clientId;
        private String clientSecret;

        public String getClientId() { return clientId; }
        public void setClientId(String clientId) { this.clientId = clientId; }
        public String getClientSecret() { return clientSecret; }
        public void setClientSecret(String clientSecret) { this.clientSecret = clientSecret; }
    }

    public void setServerUrl(String serverUrl) { this.serverUrl = serverUrl; }

    public void setRealm(String realm) { this.realm = realm; }
}