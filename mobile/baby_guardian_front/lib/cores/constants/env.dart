// lib/core/constants/env.dart

/// URLs et endpoints de ton backend / gateway.
/// Change seulement ces valeurs ici.
class Env {
  /// Gateway exposé (Cloudflare tunnel ou IP locale)
  /// ex. "https://breach-serves-respondents-indirect.trycloudflare.com"
  /// ou   "http://192.168.1.10:8081"
  /// cloudflared tunnel --url http://localhost:8081
  static const String gatewayBaseUrl =
      'https://develops-destination-soft-england.trycloudflare.com';
}
