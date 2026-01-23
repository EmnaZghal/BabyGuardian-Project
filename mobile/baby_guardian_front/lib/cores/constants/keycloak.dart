// lib/core/constants/keycloak.dart

/// Paramètres Keycloak utilisés par l'app.
class KeycloakConst {
  /// Hôte (ton tunnel Cloudflare vers Keycloak) 8080 !!!! sans https://
  /// cloudflared tunnel --url http://localhost:8080
  static const String host =

      'beverage-quantum-those-levitra.trycloudflare.com';


  /// Realm
  static const String realm = 'babyGuardian-realm';

  /// Client public Flutter
  static const String clientId = 'app-client-flutter';
}
