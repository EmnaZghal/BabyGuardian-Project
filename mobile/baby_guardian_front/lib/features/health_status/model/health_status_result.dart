class HealthStatusResult {
  final int score; // 0..100
  final String statusTitle;
  final String statusSubtitle;

  final String analysisTitle;
  final String analysisDescription;
  final List<String> bullets;

  final int monitoringDays;
  final int aiReliability;
  final String dataQuality;

  final List<String> recommendations;

  HealthStatusResult({
    required this.score,
    required this.statusTitle,
    required this.statusSubtitle,
    required this.analysisTitle,
    required this.analysisDescription,
    required this.bullets,
    required this.monitoringDays,
    required this.aiReliability,
    required this.dataQuality,
    required this.recommendations,
  });

  /// Mapping flexible من backend مختلف
  factory HealthStatusResult.fromJson(Map<String, dynamic> res) {
    int normalizeTo100(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v.clamp(0, 100);
      if (v is double) {
        if (v <= 1.0) return (v * 100).round().clamp(0, 100);
        return v.round().clamp(0, 100);
      }
      final parsed = double.tryParse(v.toString());
      if (parsed == null) return 0;
      if (parsed <= 1.0) return (parsed * 100).round().clamp(0, 100);
      return parsed.round().clamp(0, 100);
    }

    final rawScore =
        res['healthScore'] ??
        res['score'] ??
        res['value'] ??
        res['result']?['score'];

    final status =
        (res['status'] ?? res['label'] ?? res['result']?['status'] ?? 'Normal')
            .toString();

    final subtitle =
        (res['message'] ?? res['subtitle'] ?? 'Everything is fine')
            .toString();

    // bullets
    final bullets = <String>[];
    final bulletSrc =
        res['analysis'] ?? res['details'] ?? res['result']?['analysis'];
    if (bulletSrc is List) {
      for (final e in bulletSrc) {
        if (e != null) bullets.add(e.toString());
      }
    } else if (bulletSrc is Map) {
      for (final v in bulletSrc.values) {
        if (v != null) bullets.add(v.toString());
      }
    }

    // context
    String dataQuality = 'Excellent';
    int monitoringDays = 7;
    int aiReliability = 95;

    final ctxSrc = res['context'] ?? res['factors'] ?? res['result']?['context'];
    if (ctxSrc is Map) {
      // نقرأ قيم محتملة
      if (ctxSrc['Data quality'] != null) dataQuality = ctxSrc['Data quality'].toString();
      if (ctxSrc['Monitoring duration'] != null) {
        // قد تكون "7 days"
        final s = ctxSrc['Monitoring duration'].toString();
        final n = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));
        if (n != null) monitoringDays = n;
      }
      if (ctxSrc['AI reliability'] != null) {
        final s = ctxSrc['AI reliability'].toString();
        final n = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));
        if (n != null) aiReliability = n.clamp(0, 100);
      }
    }

    // recommendations
    final reco = <String>[];
    final recoSrc =
        res['recommendations'] ?? res['reco'] ?? res['result']?['recommendations'];
    if (recoSrc is List) {
      for (final e in recoSrc) {
        if (e != null) reco.add(e.toString());
      }
    }

    // fallback
    final safeBullets = bullets.isNotEmpty
        ? bullets
        : <String>[
            'Stable temperature',
            'Optimal SpO₂',
            'Regular heart rate',
          ];

    final safeReco = reco.isNotEmpty
        ? reco
        : <String>[
            'This is non-medical advice.',
            'If symptoms appear, contact a doctor.',
          ];

    return HealthStatusResult(
      score: normalizeTo100(rawScore),
      statusTitle: status,
      statusSubtitle: subtitle,
      analysisTitle: 'Positive trends',
      analysisDescription: "Your baby's vital signs look stable.",
      bullets: safeBullets,
      monitoringDays: monitoringDays,
      aiReliability: aiReliability,
      dataQuality: dataQuality,
      recommendations: safeReco,
    );
  }
}
