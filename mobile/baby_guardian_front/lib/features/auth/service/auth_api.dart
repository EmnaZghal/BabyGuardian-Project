import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:baby_guardian_front/cores/constants/env.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class AuthApi {
  static Future<void> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${Env.gatewayBaseUrl}/auth/signup');

    try {
      final res = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': fullName.trim(),
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 12));

      // Succes 2xx
      if (res.statusCode >= 200 && res.statusCode < 300) return;

      // Essaie de lire le message backend { "message": "..." }
      String? backendMsg;
      try {
        backendMsg = (jsonDecode(res.body) as Map?)?['message']?.toString();
      } catch (_) {}

      // Cas fréquents
      if (res.statusCode == 409) {
        throw ApiException(409, backendMsg ?? 'Email already in use');
      }
      if (res.statusCode == 400) {
        throw ApiException(400, backendMsg ?? 'Invalid data');
      }

      throw ApiException(res.statusCode, backendMsg ?? 'Signup failed (${res.statusCode})');
    } on TimeoutException {
      throw ApiException(408, 'Request timed out, please try again');
    } on SocketException {
      throw ApiException(0, 'Network error: check your connection');
    }
  }
}
