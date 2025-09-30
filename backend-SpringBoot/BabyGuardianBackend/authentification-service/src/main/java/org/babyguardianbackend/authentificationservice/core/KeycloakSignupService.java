package org.babyguardianbackend.authentificationservice.core;

import org.babyguardianbackend.authentificationservice.config.KeycloakAdminProperties;
import org.keycloak.OAuth2Constants;
import org.keycloak.admin.client.CreatedResponseUtil;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.KeycloakBuilder;
import org.keycloak.admin.client.resource.RealmResource;
import org.keycloak.admin.client.resource.UsersResource;
import org.keycloak.representations.idm.CredentialRepresentation;
import org.keycloak.representations.idm.RoleRepresentation;
import org.keycloak.representations.idm.UserRepresentation;
import org.springframework.stereotype.Service;

import jakarta.ws.rs.core.Response;
import java.util.Collections;
import java.util.List;

@Service
public class KeycloakSignupService {

    private final KeycloakAdminProperties props;

    public KeycloakSignupService(KeycloakAdminProperties props) {
        this.props = props;
    }

    private Keycloak adminKC() {
        // Le client admin vit dans le MÊME realm que tu gères
        return KeycloakBuilder.builder()
                .serverUrl(props.getServerUrl())
                .realm(props.getRealm())
                .clientId(props.getAdmin().getClientId())
                .clientSecret(props.getAdmin().getClientSecret())
                .grantType(OAuth2Constants.CLIENT_CREDENTIALS)
                .build();
    }

    public String signup(String fullName, String email, String password) {
        // Normalisation basique (trim + lower pour éviter faux doublons)
        final String normEmail = email == null ? null : email.trim().toLowerCase();
        String first = fullName == null ? "" : fullName.trim();
        String last = "";
        int sp = first.indexOf(' ');
        if (sp > 0) { last = first.substring(sp + 1).trim(); first = first.substring(0, sp).trim(); }

        try (Keycloak kc = adminKC()) {
            RealmResource realm = kc.realm(props.getRealm());
            UsersResource users = realm.users();

            // === 1) Pré-vérifs stricts (pas de doublons) =========================
            // username = email chez nous
            if (!users.searchByUsername(normEmail, true).isEmpty()) {
                throw new EmailAlreadyUsedException();
            }

            if (!searchEmailExact(users, normEmail).isEmpty()) {
                throw new EmailAlreadyUsedException();
            }

            // === 2) Création de l'utilisateur ===================================
            UserRepresentation ur = new UserRepresentation();
            ur.setUsername(normEmail);
            ur.setEmail(normEmail);
            ur.setFirstName(first);
            ur.setLastName(last);
            ur.setEnabled(true);
            ur.setEmailVerified(false);

            Response resp = users.create(ur);
            int status = resp.getStatus();
            // 409 peut encore arriver si une course se produit entre la pré-vérif et la création
            if (status == 409) throw new EmailAlreadyUsedException();
            if (status >= 300) throw new RuntimeException("Keycloak create failed: " + status);
            String userId = CreatedResponseUtil.getCreatedId(resp);

            // === 3) Définir le mot de passe =====================================
            CredentialRepresentation pwd = new CredentialRepresentation();
            pwd.setType(CredentialRepresentation.PASSWORD);
            pwd.setTemporary(false);
            pwd.setValue(password);
            users.get(userId).resetPassword(pwd);

            // === 4) Rôle realm "user" ============================================
            RoleRepresentation role = realm.roles().get("user").toRepresentation();
            users.get(userId).roles().realmLevel().add(Collections.singletonList(role));

            return userId;
        }
    }

    /**
     * Recherche d'email *exacte*.
     * - Utilise searchByEmail(email, true) si dispo (Keycloak Admin Client 24+)
     * - Sinon fallback vers l’ancienne signature verbeuse.
     */
    private List<UserRepresentation> searchEmailExact(UsersResource users, String email) {
        // 1) Essaye l’API moderne si elle existe (Keycloak Admin Client ≥ 24)
        try {
            return users.searchByEmail(email, true);
        } catch (Throwable ignore) {
            // 2) Fallback universel : recherche large, puis filtrage exact côté Java
            //    (toutes les versions ont au moins search(String))
            List<UserRepresentation> candidates = users.search(email);
            return candidates.stream()
                    .filter(u -> u.getEmail() != null && u.getEmail().equalsIgnoreCase(email))
                    .toList();
        }
    }
}
