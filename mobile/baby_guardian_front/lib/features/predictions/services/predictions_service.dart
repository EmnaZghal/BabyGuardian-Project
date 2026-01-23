import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:baby_guardian_front/cores/constants/env.dart';
import '../../auth/service/auth_service.dart';

class PredictionsService {
  final http.Client _client;
  final AuthService _auth;

  PredictionsService({http.Client? client, AuthService? authService})
      : _client = client ?? http.Client(),
        _auth = authService ?? AuthService();

  Future<Map<String, dynamic>> predictHourly({
    required String deviceId,
    required int subjectId,
    required DateTime hourTs,
    required int age,
    required int sexBin, // 0/1
    required int heightCm,
    required int weightKg,
  }) async {
    final url = Uri.parse('${Env.gatewayBaseUrl}/feature-ml-service/api/predict/hourly');

    final payload = {
      'deviceId': deviceId,
      'subjectId': subjectId,
      'hourTs': hourTs.toUtc().toIso8601String(),
      'age': age,
      'sexBin': sexBin,
      'heightCm': heightCm,
      'weightKg': weightKg,
    };

    // token valide (refresh auto si tu as ajouté getValidAccessToken)
    // sinon on fait fallback: getAccessToken + refresh sur 401
    String? token = await _auth.getAccessToken();

    http.Response resp = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (resp.statusCode == 401) {
      final ok = await _auth.refresh();
      if (ok) {
        token = await _auth.getAccessToken();
        resp = await _client.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        );
      }
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }

    final body = resp.body.trim();
    if (body.isEmpty) return {};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;

    // si backend renvoie autre chose
    return {'raw': decoded};
  }

  void dispose() => _client.close();
}
