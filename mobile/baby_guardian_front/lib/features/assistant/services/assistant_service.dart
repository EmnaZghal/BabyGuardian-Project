import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth/service/auth_service.dart';

class AssistantService {
  final String baseUrl;
  final http.Client _client;
  final AuthService _auth;

  AssistantService({
    required this.baseUrl,
    http.Client? client,
    AuthService? authService,
  })  : _client = client ?? http.Client(),
        _auth = authService ?? AuthService();

  /// POST /chatbot-service/api/chat
  /// Body: { message, babyId, intent }
  Future<String> sendMessage({
    required String message,
    required String babyId,
    String? intent,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl/chatbot-service/api/chat');

    final payload = <String, dynamic>{
      'message': message,
      'babyId': babyId,
      if (intent != null && intent.trim().isNotEmpty) 'intent': intent.trim(),
    };

    // 1) Lire token
    String? token = await _auth.getAccessToken();

    // 2) Essai 1
    http.Response resp = await _postWithToken(
      url: url,
      payload: payload,
      token: token,
      extraHeaders: headers,
    );

    // 3) Si 401 → refresh puis retry 1 fois
    if (resp.statusCode == 401) {
      final refreshed = await _auth.refresh();
      if (refreshed) {
        token = await _auth.getAccessToken();
        resp = await _postWithToken(
          url: url,
          payload: payload,
          token: token,
          extraHeaders: headers,
        );
      }
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }

    // Parse réponse
    final body = resp.body.trim();
    if (body.isEmpty) return '';

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        final candidates = ['reply', 'message', 'answer', 'content', 'text'];
        for (final k in candidates) {
          final v = decoded[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        return jsonEncode(decoded);
      }

      if (decoded is String) return decoded.trim();

      return decoded.toString();
    } catch (_) {
      return body;
    }
  }

  Future<http.Response> _postWithToken({
    required Uri url,
    required Map<String, dynamic> payload,
    required String? token,
    Map<String, String>? extraHeaders,
  }) {
    return _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.trim().isNotEmpty)
          'Authorization': 'Bearer ${token.trim()}',
        if (extraHeaders != null) ...extraHeaders,
      },
      body: jsonEncode(payload),
    );
  }

  void dispose() {
    _client.close();
  }
}
