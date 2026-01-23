import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:baby_guardian_front/cores/constants/keycloak.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Uri get _tokenEndpoint => Uri.https(
        KeycloakConst.host,
        '/realms/${KeycloakConst.realm}/protocol/openid-connect/token',
      );

  Future<bool> loginWithPassword(String username, String password) async {
    print('🔐 LOGIN ATTEMPT');
    print('   Username: $username');
    print('   Endpoint: $_tokenEndpoint');

    try {
      final resp = await http.post(
        _tokenEndpoint,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'client_id': KeycloakConst.clientId,
          'username': username,
          'password': password,
          'scope': 'openid profile email offline_access',
        },
      );

      print('📥 LOGIN RESPONSE: ${resp.statusCode}');

      if (resp.statusCode != 200) {
        print('❌ Login failed: ${resp.body}');
        return false;
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final accessToken = json['access_token'] as String?;
      final refreshToken = json['refresh_token'] as String?;
      final idToken = json['id_token'] as String?;

      if (accessToken == null) {
        print('❌ No access token in response');
        return false;
      }

      print('✅ Tokens received:');
      print('   Access: ${accessToken.substring(0, 30)}...');
      print('   Refresh: ${refreshToken?.substring(0, 30) ?? "none"}...');

      await _storage.write(key: 'access_token', value: accessToken);
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }
      if (idToken != null) {
        await _storage.write(key: 'id_token', value: idToken);
      }

      print('✅ Login successful');
      return true;
    } catch (e) {
      print('❌ Login exception: $e');
      return false;
    }
  }

  Future<bool> refresh() async {
    print('🔄 REFRESH TOKEN ATTEMPT');

    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      print('❌ No refresh token available');
      return false;
    }

    print('   Using refresh token: ${refreshToken.substring(0, 30)}...');

    try {
      final resp = await http.post(
        _tokenEndpoint,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'client_id': KeycloakConst.clientId,
          'refresh_token': refreshToken,
        },
      );

      print('📥 REFRESH RESPONSE: ${resp.statusCode}');

      if (resp.statusCode != 200) {
        print('❌ Refresh failed: ${resp.body}');
        return false;
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final accessToken = json['access_token'] as String?;
      final newRefresh = json['refresh_token'] as String?;

      if (accessToken == null) {
        print('❌ No access token in refresh response');
        return false;
      }

      await _storage.write(key: 'access_token', value: accessToken);
      if (newRefresh != null) {
        await _storage.write(key: 'refresh_token', value: newRefresh);
      }

      print('✅ Token refreshed successfully');
      return true;
    } catch (e) {
      print('❌ Refresh exception: $e');
      return false;
    }
  }

  Future<void> logout() async {
    print('🚪 LOGOUT - Clearing all tokens');
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      print('📌 Retrieved token (first 30): ${token.substring(0, 30)}...');
    } else {
      print('⚠️ No access token found in storage');
    }
    return token;
  }
}