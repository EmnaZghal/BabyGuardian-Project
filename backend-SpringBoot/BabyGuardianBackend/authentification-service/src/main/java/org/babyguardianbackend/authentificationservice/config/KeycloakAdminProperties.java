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
        /**
         * Realm utilisé pour obtenir le token admin (souvent "master").
         * Si non défini, on utilise {@code keycloak.realm}.
         */
        private String tokenRealm;
        /**
         * Type de grant OAuth2 pour l'admin client Keycloak.
         * Valeurs supportées: "client_credentials" (défaut) ou "password".
         */
        private String grantType;

        // Utilisé si grantType=password
        private String username;
        private String password;

        public String getClientId() { return clientId; }
        public void setClientId(String clientId) { this.clientId = clientId; }
        public String getClientSecret() { return clientSecret; }
        public void setClientSecret(String clientSecret) { this.clientSecret = clientSecret; }
        public String getTokenRealm() { return tokenRealm; }
        public void setTokenRealm(String tokenRealm) { this.tokenRealm = tokenRealm; }
        public String getGrantType() { return grantType; }
        public void setGrantType(String grantType) { this.grantType = grantType; }
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }

    public void setServerUrl(String serverUrl) { this.serverUrl = serverUrl; }

    public void setRealm(String realm) { this.realm = realm; }
}
