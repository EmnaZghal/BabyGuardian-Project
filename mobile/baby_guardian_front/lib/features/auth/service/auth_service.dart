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
      if (resp.statusCode != 200) return false;

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final accessToken = json['access_token'] as String?;
      final refreshToken = json['refresh_token'] as String?;
      final idToken = json['id_token'] as String?;

      if (accessToken == null) return false;

      await _storage.write(key: 'access_token', value: accessToken);
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }
      if (idToken != null) {
        await _storage.write(key: 'id_token', value: idToken);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> refresh() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

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
      if (resp.statusCode != 200) return false;

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final accessToken = json['access_token'] as String?;
      final newRefresh = json['refresh_token'] as String?;
      if (accessToken == null) return false;

      await _storage.write(key: 'access_token', value: accessToken);
      if (newRefresh != null) {
        await _storage.write(key: 'refresh_token', value: newRefresh);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async => _storage.deleteAll();

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
}
