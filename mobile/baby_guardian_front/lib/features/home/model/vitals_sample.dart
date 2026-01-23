// lib/features/home/models/vitals_sample.dart
class VitalsSample {
  final double? temp;
  final double? spo2;
  final double? hr;
  final double? humidity;

  VitalsSample({
    required this.temp,
    required this.spo2,
    required this.hr,
    required this.humidity,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory VitalsSample.fromJson(Map<String, dynamic> json) {
    return VitalsSample(
      temp: _toDouble(json['temp'] ?? json['temperature']),
      spo2: _toDouble(json['spo2'] ?? json['oxygen']),
      hr: _toDouble(json['hr'] ?? json['heartRate']),
      humidity: _toDouble(json['humidity']),
    );
  }
}
