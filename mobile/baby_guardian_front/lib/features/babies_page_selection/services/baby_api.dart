import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:baby_guardian_front/cores/constants/env.dart';
import 'package:baby_guardian_front/features/babies_page_selection/models/baby_create_request.dart';
import 'package:baby_guardian_front/features/babies_page_selection/models/baby_create_response.dart';
import 'package:baby_guardian_front/features/auth/service/auth_service.dart';
import 'package:baby_guardian_front/cores/network/api_exception.dart';

class BabyApi {
  static Uri get _endpoint =>
      Uri.parse('${Env.gatewayBaseUrl}/profile-service/api/babies');

  /// Vérifie si le token est expiré en décodant le JWT
  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode le payload (partie centrale du JWT)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = json['exp'] as int?;
      if (exp == null) return true;

      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Token expiré si moins de 30 secondes restantes
      return expDate.isBefore(now.add(const Duration(seconds: 30)));
    } catch (e) {
      print('❌ Error checking token expiry: $e');
      return true;
    }
  }

  /// Obtient un token valide (refresh si nécessaire)
  static Future<String> _getValidToken(AuthService auth) async {
    String? token = await auth.getAccessToken();

    if (token == null || token.isEmpty) {
      throw ApiException(
        401,
        'No access token found. Please login again.',
        endpoint: _endpoint.toString(),
      );
    }

    // Vérifie si le token est expiré
    if (_isTokenExpired(token)) {
      print('🔄 Token expired, refreshing...');
      
      final refreshed = await auth.refresh();
      if (!refreshed) {
        throw ApiException(
          401,
          'Token expired and refresh failed. Please login again.',
          endpoint: _endpoint.toString(),
        );
      }

      token = await auth.getAccessToken();
      if (token == null || token.isEmpty) {
        throw ApiException(
          401,
          'Token refresh did not return a valid token.',
          endpoint: _endpoint.toString(),
        );
      }

      print('✅ Token refreshed successfully');
    }

    return token;
  }

  static Future<BabyCreateResponse> createBaby({
    required AuthService auth,
    required BabyCreateRequest body,
  }) async {
    final endpointStr = _endpoint.toString();

    // 1️⃣ Obtenir un token VALIDE (avec refresh automatique si nécessaire)
    final token = await _getValidToken(auth);

    print('📤 CREATE BABY REQUEST');
    print('   Endpoint: $endpointStr');
    print('   Token (first 30 chars): ${token.substring(0, 30)}...');
    print('   Body: ${jsonEncode(body.toJson())}');

    try {
      final res = await http
          .post(
            _endpoint,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body.toJson()),
          )
          .timeout(const Duration(seconds: 12));

      print('📥 RESPONSE: ${res.statusCode}');
      print('   Body: ${res.body}');
      print('   Headers: ${res.headers}');

      // ✅ Succès
      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final json = jsonDecode(res.body) as Map<String, dynamic>;
          return BabyCreateResponse.fromJson(json);
        } catch (e) {
          print('❌ Failed to parse response: $e');
          throw ApiException(
            res.statusCode,
            'Invalid response format from server',
            endpoint: endpointStr,
            rawBody: _truncate(res.body),
          );
        }
      }

      // ❌ Erreur - Essayer d'extraire le message du backend
      String? backendMsg;
      try {
        final json = jsonDecode(res.body) as Map<String, dynamic>?;
        backendMsg = json?['message']?.toString() ?? 
                     json?['error']?.toString() ??
                     json?['detail']?.toString();
      } catch (_) {
        // Body pas JSON
      }

      final errorMsg = backendMsg ?? 
                      'Create baby failed (HTTP ${res.statusCode})';

      throw ApiException(
        res.statusCode,
        errorMsg,
        endpoint: endpointStr,
        rawBody: _truncate(res.body),
      );

    } on TimeoutException {
      throw ApiException(
        408,
        'Request timed out - server took too long to respond',
        endpoint: endpointStr,
      );
    } on SocketException catch (e) {
      throw ApiException(
        0,
        'Network error: ${e.message}',
        endpoint: endpointStr,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        500,
        'Unexpected error: $e',
        endpoint: endpointStr,
      );
    }
  }

  static String _truncate(String s, {int max = 800}) {
    final t = s.trim();
    if (t.isEmpty) return '(empty)';
    if (t.length <= max) return t;
    return '${t.substring(0, max)}...';
  }
}