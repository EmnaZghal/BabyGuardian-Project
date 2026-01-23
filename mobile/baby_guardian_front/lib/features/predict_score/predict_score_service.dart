import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictScoreService {
  final http.Client _client = http.Client();

  // 🔁 Change ça selon ton env
  final String baseUrl = 'http://localhost:8081';

  Future<Map<String, dynamic>> predictHealthScoreHourly({
    required String deviceId,
    required String hourEnd, // ISO string
    required int expectedSamples,
    required int gestationalAgeWeeks,
    required int gender,
    required int ageDays,
    required double weightKg,
  }) async {
    final url = Uri.parse('$baseUrl/feature-ml-service/api/health-score/hourly');

    final payload = {
      "deviceId": deviceId,
      "hourEnd": hourEnd,
      "expectedSamples": expectedSamples,
      "gestationalAgeWeeks": gestationalAgeWeeks,
      "gender": gender,
      "ageDays": ageDays,
      "weightKg": weightKg,
    };

    final resp = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);

    throw Exception('Unexpected response: ${resp.body}');
  }

  void dispose() => _client.close();
}
