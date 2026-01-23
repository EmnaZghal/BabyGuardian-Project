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
  static Uri get _babiesEndpoint =>
      Uri.parse('${Env.gatewayBaseUrl}/profile-service/api/babies');

  static Uri _bindEndpoint(String babyId) => Uri.parse(
        '${Env.gatewayBaseUrl}/profile-service/api/babies/$babyId/bind-device',
      );

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
    } catch (_) {
      return true;
    }
  }

  static Future<String> _getValidToken(AuthService auth, String endpointStr) async {
    String? token = await auth.getAccessToken();

    if (token == null || token.isEmpty) {
      print('❌ [API] No access token found for: $endpointStr');
      throw ApiException(401, 'No access token found. Please login again.',
          endpoint: endpointStr);
    }

    if (_isTokenExpired(token)) {
      print('⏳ [API] Access token expired -> refreshing...');
      final refreshed = await auth.refresh();
      if (!refreshed) {
        print('❌ [API] Token refresh failed');
        throw ApiException(401, 'Token expired and refresh failed. Please login again.',
            endpoint: endpointStr);
      }

      token = await auth.getAccessToken();
      if (token == null || token.isEmpty) {
        print('❌ [API] Refresh succeeded but returned empty token');
        throw ApiException(401, 'Token refresh did not return a valid token.',
            endpoint: endpointStr);
      }
      print('✅ [API] Token refreshed OK');
    }

    return token;
  }

  static Future<http.Response> _postAuthed(
    AuthService auth,
    Uri endpoint, {
    required Object body,
  }) async {
    final endpointStr = endpoint.toString();
    final token = await _getValidToken(auth, endpointStr);

    // ✅ LOG REQUEST
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 [API] POST => $endpointStr');
    print('📦 [API] Body => $body');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    http.Response res = await http
        .post(
          endpoint,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 12));

    // ✅ LOG RESPONSE
    print('📥 [API] Response status: ${res.statusCode}');
    print('📥 [API] Response body  : ${_truncate(res.body)}');

    // retry once if 401
    if (res.statusCode == 401) {
      print('⚠️ [API] 401 Unauthorized -> trying refresh + retry once');

      final ok = await auth.refresh();
      if (ok) {
        final newToken = await auth.getAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          print('🔁 [API] Retrying POST after refresh...');

          res = await http
              .post(
                endpoint,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $newToken',
                },
                body: body,
              )
              .timeout(const Duration(seconds: 12));

          print('📥 [API] Retry response status: ${res.statusCode}');
          print('📥 [API] Retry response body  : ${_truncate(res.body)}');
        } else {
          print('❌ [API] Refresh OK but new token is empty -> no retry');
        }
      } else {
        print('❌ [API] Refresh failed -> no retry');
      }
    }

    return res;
  }

  static Future<BabyCreateResponse> createBaby({
    required AuthService auth,
    required BabyCreateRequest body,
  }) async {
    final endpoint = _babiesEndpoint;
    final endpointStr = endpoint.toString();

    try {
      print('🍼 [BabyApi] createBaby()...');
      final res = await _postAuthed(auth, endpoint, body: jsonEncode(body.toJson()));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        print('✅ [BabyApi] createBaby OK');
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        return BabyCreateResponse.fromJson(map);
      }

      print('❌ [BabyApi] createBaby FAILED (HTTP ${res.statusCode})');
      final msg = _tryExtractBackendMessage(res.body) ??
          'Create baby failed (HTTP ${res.statusCode})';

      throw ApiException(
        res.statusCode,
        msg,
        endpoint: endpointStr,
        rawBody: _truncate(res.body),
      );
    } on TimeoutException {
      print('⏰ [BabyApi] createBaby TIMEOUT');
      throw ApiException(408, 'Request timed out', endpoint: endpointStr);
    } on SocketException catch (e) {
      print('🌐 [BabyApi] createBaby NETWORK ERROR: ${e.message}');
      throw ApiException(0, 'Network error: ${e.message}', endpoint: endpointStr);
    }
  }

  static Future<void> bindDevice({
    required AuthService auth,
    required String babyId,
    required String deviceId,
  }) async {
    final endpoint = _bindEndpoint(babyId);
    final endpointStr = endpoint.toString();

    final payload = {'device_id': deviceId};

    try {
      print('🔗 [BabyApi] bindDevice()...');
      print('👶 [BabyApi] babyId   : $babyId');
      print('📟 [BabyApi] deviceId : $deviceId');

      final res = await _postAuthed(auth, endpoint, body: jsonEncode(payload));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        print('✅ [BabyApi] bindDevice OK');
        return;
      }

      print('❌ [BabyApi] bindDevice FAILED (HTTP ${res.statusCode})');

      final msg = _tryExtractBackendMessage(res.body) ??
          'Bind device failed (HTTP ${res.statusCode})';

      throw ApiException(
        res.statusCode,
        msg,
        endpoint: endpointStr,
        rawBody: _truncate(res.body),
      );
    } on TimeoutException {
      print('⏰ [BabyApi] bindDevice TIMEOUT');
      throw ApiException(408, 'Request timed out', endpoint: endpointStr);
    } on SocketException catch (e) {
      print('🌐 [BabyApi] bindDevice NETWORK ERROR: ${e.message}');
      throw ApiException(0, 'Network error: ${e.message}', endpoint: endpointStr);
    }
  }

  static String? _tryExtractBackendMessage(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            decoded['detail']?.toString() ??
            decoded['error_description']?.toString() ??
            decoded['title']?.toString();
      }
    } catch (_) {}
    return null;
  }

  static String _truncate(String s, {int max = 800}) {
    final t = s.trim();
    if (t.isEmpty) return '(empty)';
    if (t.length <= max) return t;
    return '${t.substring(0, max)}...';
  }
}
