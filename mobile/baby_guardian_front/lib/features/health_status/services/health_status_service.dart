import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:baby_guardian_front/cores/constants/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class HealthStatusService {
  final http.Client _client;
  final FlutterSecureStorage _storage;

  HealthStatusService({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  void dispose() => _client.close();

  Future<Map<String, dynamic>> predictHealthScoreHourly({
    required String deviceId,
    required DateTime hourEnd,
    required int expectedSamples,
    required int gestationalAgeWeeks,
    required int gender,
    required int ageDays,
    required double weightKg,
  }) async {
    final uri = Uri.parse(
      '${Env.gatewayBaseUrl}/feature-ml-service/api/health-score/hourly',
    );

    final token = await _storage.read(key: 'access_token');

    try {
      final res = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'deviceId': deviceId,
              'hourEnd': hourEnd.toUtc().toIso8601String(),
              'expectedSamples': expectedSamples,
              'gestationalAgeWeeks': gestationalAgeWeeks,
              'gender': gender,
              'ageDays': ageDays,
              'weightKg': weightKg,
            }),
          )
          .timeout(const Duration(seconds: 18));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        throw ApiException(res.statusCode, 'Unexpected response format');
      }

      String? backendMsg;
      try {
        backendMsg = (jsonDecode(res.body) as Map?)?['message']?.toString();
      } catch (_) {}

      throw ApiException(
        res.statusCode,
        backendMsg ?? 'Request failed (${res.statusCode})',
      );
    } on TimeoutException {
      throw ApiException(408, 'Request timed out, please try again');
    } on SocketException {
      throw ApiException(0, 'Network error: check your connection');
    }
  }
}
