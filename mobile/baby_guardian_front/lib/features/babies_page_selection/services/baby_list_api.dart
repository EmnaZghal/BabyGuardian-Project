import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:baby_guardian_front/cores/constants/env.dart';
import 'package:baby_guardian_front/features/auth/service/auth_service.dart';
import 'package:baby_guardian_front/cores/network/api_exception.dart';

/// ✅ API dédiée pour récupérer la liste des bébés de l'utilisateur
/// Endpoint: GET /profile-service/api/me/babies
class BabyListApi {
  static Uri get _endpoint =>
      Uri.parse('${Env.gatewayBaseUrl}/profile-service/api/me/babies');

  /// Copier la logique "token expiré ?" identique à BabyApi
  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = json['exp'] as int?;
      if (exp == null) return true;

      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      return expDate.isBefore(now.add(const Duration(seconds: 30)));
    } catch (e) {
      return true;
    }
  }

  static Future<String> _getValidToken(AuthService auth) async {
    String? token = await auth.getAccessToken();

    if (token == null || token.isEmpty) {
      throw ApiException(
        401,
        'No access token found. Please login again.',
        endpoint: _endpoint.toString(),
      );
    }

    if (_isTokenExpired(token)) {
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
    }

    return token;
  }

  /// ✅ Retourne une List<Map> (tu peux mapper vers ton model ensuite)
  static Future<List<Map<String, dynamic>>> getMyBabies({
    required AuthService auth,
  }) async {
    final endpointStr = _endpoint.toString();

    // 1) token valide (refresh auto)
    final token = await _getValidToken(auth);

    try {
      final res = await http
          .get(
            _endpoint,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 12));

      // ✅ OK
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);

        // backend: soit List directement
        if (decoded is List) {
          return decoded
              .whereType<dynamic>()
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }

        // backend: soit {items:[...]} ou {babies:[...]}
        if (decoded is Map) {
          final items = decoded['items'] ?? decoded['babies'];
          if (items is List) {
            return items
                .whereType<dynamic>()
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
        }

        throw ApiException(
          res.statusCode,
          'Invalid response format from server',
          endpoint: endpointStr,
          rawBody: _truncate(res.body),
        );
      }

      // ❌ erreurs
      String? backendMsg;
      try {
        final json = jsonDecode(res.body) as Map<String, dynamic>?;
        backendMsg = json?['message']?.toString() ??
            json?['error']?.toString() ??
            json?['detail']?.toString();
      } catch (_) {}

      throw ApiException(
        res.statusCode,
        backendMsg ?? 'Get babies failed (HTTP ${res.statusCode})',
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
