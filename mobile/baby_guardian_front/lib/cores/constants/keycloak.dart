// lib/core/constants/keycloak.dart

/// Paramètres Keycloak utilisés par l'app.
class KeycloakConst {
  /// Hôte (ton tunnel Cloudflare vers Keycloak)
  static const String host =
      'seas-trend-agent-higher.trycloudflare.com';

  /// Realm
  static const String realm = 'babyGuardian-realm';

  /// Client public Flutter
  static const String clientId = 'app-client-flutter';
}
