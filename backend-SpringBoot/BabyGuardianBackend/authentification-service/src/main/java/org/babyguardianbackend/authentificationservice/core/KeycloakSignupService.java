package org.babyguardianbackend.authentificationservice.core;

import org.babyguardianbackend.authentificationservice.config.KeycloakAdminProperties;
import org.keycloak.OAuth2Constants;
import org.keycloak.admin.client.CreatedResponseUtil;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.KeycloakBuilder;
import org.keycloak.admin.client.resource.RealmResource;
import org.keycloak.admin.client.resource.UsersResource;
import org.keycloak.representations.idm.CredentialRepresentation;
import org.keycloak.representations.idm.UserRepresentation;
import org.springframework.stereotype.Service;

import jakarta.ws.rs.core.Response;
import java.util.List;

@Service
public class KeycloakSignupService {

    private final KeycloakAdminProperties props;

    public KeycloakSignupService(KeycloakAdminProperties props) {
        this.props = props;
    }

    private Keycloak adminKC() {
        String tokenRealm = props.getAdmin().getTokenRealm();
        if (tokenRealm == null || tokenRealm.isBlank()) {
            tokenRealm = props.getRealm(); // défaut
        }

        String grantType = props.getAdmin().getGrantType();
        if (grantType == null || grantType.isBlank()) {
            grantType = OAuth2Constants.CLIENT_CREDENTIALS;
        }

        KeycloakBuilder b = KeycloakBuilder.builder()
                .serverUrl(props.getServerUrl())
                .realm(tokenRealm)
                .clientId(props.getAdmin().getClientId())
                .grantType(grantType);

        if (OAuth2Constants.CLIENT_CREDENTIALS.equals(grantType)) {
            b.clientSecret(props.getAdmin().getClientSecret());
        } else if (OAuth2Constants.PASSWORD.equals(grantType)) {
            b.username(props.getAdmin().getUsername());
            b.password(props.getAdmin().getPassword());
        } else {
            throw new IllegalArgumentException("Unsupported grantType: " + grantType);
        }

        return b.build();
    }

    public String signup(String fullName, String email, String password) {
        final String normEmail = email == null ? null : email.trim().toLowerCase();

        String first = fullName == null ? "" : fullName.trim();
        String last = "";
        int sp = first.indexOf(' ');
        if (sp > 0) { last = first.substring(sp + 1).trim(); first = first.substring(0, sp).trim(); }

        try (Keycloak kc = adminKC()) {
            RealmResource realm = kc.realm(props.getRealm());
            UsersResource users = realm.users();

            // doublons
            if (!users.searchByUsername(normEmail, true).isEmpty()) throw new EmailAlreadyUsedException();
            if (!searchEmailExact(users, normEmail).isEmpty()) throw new EmailAlreadyUsedException();

            // password directement dans la création (évite resetPassword())
            CredentialRepresentation pwd = new CredentialRepresentation();
            pwd.setType(CredentialRepresentation.PASSWORD);
            pwd.setTemporary(false);
            pwd.setValue(password);

            UserRepresentation ur = new UserRepresentation();
            ur.setUsername(normEmail);
            ur.setEmail(normEmail);
            ur.setFirstName(first);
            ur.setLastName(last);
            ur.setEnabled(true);
            ur.setEmailVerified(false);
            ur.setCredentials(List.of(pwd));

            try (Response resp = users.create(ur)) {
                int status = resp.getStatus();

                if (status == 409) throw new EmailAlreadyUsedException();
                if (status < 200 || status >= 300) {
                    throw new KeycloakAdminException(status, "Create user failed");
                }

                return CreatedResponseUtil.getCreatedId(resp);
            }
        }
    }

    private List<UserRepresentation> searchEmailExact(UsersResource users, String email) {
        try {
            return users.searchByEmail(email, true);
        } catch (Throwable ignore) {
            List<UserRepresentation> candidates = users.search(email);
            return candidates.stream()
                    .filter(u -> u.getEmail() != null && u.getEmail().equalsIgnoreCase(email))
                    .toList();
        }
    }
}
