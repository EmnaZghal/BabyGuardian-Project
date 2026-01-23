import 'package:flutter/material.dart';
import '../predict_score_service.dart';

class PredictScorePage extends StatefulWidget {
  const PredictScorePage({super.key});

  @override
  State<PredictScorePage> createState() => _PredictScorePageState();
}

class _PredictScorePageState extends State<PredictScorePage> {
  final _svc = PredictScoreService();

  final _deviceId = TextEditingController(text: 'esp32-c00aa81f8a3c');
  final _hourEnd = TextEditingController(); // auto rempli
  final _expectedSamples = TextEditingController(text: '12');
  final _gestWeeks = TextEditingController(text: '38');
  final _ageDays = TextEditingController(text: '10');
  final _weightKg = TextEditingController(text: '3.2');

  int _gender = 1; // 0/1

  bool _loading = false;
  String? _error;

  // Résultat
  double? _score; // 0..100
  String _status = 'Normal';
  String _subtitle = 'Everything looks fine.';
  double _aiReliability = 0.95; // 0..1
  String _dataQuality = 'Excellent';
  String _monitoringDuration = '7 days';

  // Détails affichage
  List<_InsightItem> _insights = const [
    _InsightItem("Stable temperature", "Normal"),
    _InsightItem("Optimal SpO₂", "Normal"),
    _InsightItem("Regular heart rate", "Normal"),
  ];

  List<String> _recommendations = const [
    "Continue regular monitoring.",
    "If symptoms appear, consult a doctor.",
  ];

  @override
  void initState() {
    super.initState();
    _hourEnd.text = DateTime.now().toUtc().toIso8601String();
  }

  @override
  void dispose() {
    _svc.dispose();
    _deviceId.dispose();
    _hourEnd.dispose();
    _expectedSamples.dispose();
    _gestWeeks.dispose();
    _ageDays.dispose();
    _weightKg.dispose();
    super.dispose();
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Future<void> _predictScore() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _svc.predictHealthScoreHourly(
        deviceId: _deviceId.text.trim(),
        hourEnd: _hourEnd.text.trim(),
        expectedSamples: int.parse(_expectedSamples.text.trim()),
        gestationalAgeWeeks: int.parse(_gestWeeks.text.trim()),
        gender: _gender,
        ageDays: int.parse(_ageDays.text.trim()),
        weightKg: double.parse(_weightKg.text.trim()),
      );

      // ✅ Mapping flexible : adapte selon ton backend
      // Exemples possibles:
      // { "score": 87, "status": "Normal", "aiReliability": 0.95, "insights":[...], "recommendations":[...] }

      final score = _toDouble(res['score'] ?? res['healthScore'] ?? res['value']);
      final status = (res['status'] ?? res['level'] ?? 'Normal').toString();
      final subtitle = (res['subtitle'] ?? res['message'] ?? 'Everything is fine.').toString();

      final aiRel = _toDouble(res['aiReliability'] ?? res['reliability']) ?? 0.95;
      final dataQ = (res['dataQuality'] ?? 'Excellent').toString();
      final duration = (res['monitoringDuration'] ?? '7 days').toString();

      // Insights
      final insightsJson = res['insights'] ?? res['details'] ?? res['analysis'];
      final insights = <_InsightItem>[];
      if (insightsJson is List) {
        for (final e in insightsJson) {
          if (e is Map) {
            final m = Map<String, dynamic>.from(e);
            insights.add(_InsightItem(
              (m['title'] ?? m['label'] ?? 'Insight').toString(),
              (m['status'] ?? m['value'] ?? 'Normal').toString(),
            ));
          }
        }
      }

      // Recommendations
      final recJson = res['recommendations'] ?? res['tips'];
      final recs = <String>[];
      if (recJson is List) {
        for (final e in recJson) {
          recs.add(e.toString());
        }
      }

      setState(() {
        _score = score ?? _score;
        _status = status;
        _subtitle = subtitle;
        _aiReliability = aiRel;
        _dataQuality = dataQ;
        _monitoringDuration = duration;
        if (insights.isNotEmpty) _insights = insights;
        if (recs.isNotEmpty) _recommendations = recs;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = _score;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Non-medical advice'),
                  content: const Text(
                    "This score is an AI estimation and does not replace a medical diagnosis.",
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FormCard(
            deviceId: _deviceId,
            hourEnd: _hourEnd,
            expectedSamples: _expectedSamples,
            gestWeeks: _gestWeeks,
            ageDays: _ageDays,
            weightKg: _weightKg,
            gender: _gender,
            onGenderChanged: (v) => setState(() => _gender = v),
            onPredict: _loading ? null : _predictScore,
          ),
          const SizedBox(height: 14),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(),
              ),
            ),

          if (_error != null) ...[
            _ErrorCard(message: _error!),
            const SizedBox(height: 12),
          ],

          // ✅ Résultat (design pro)
          if (score != null) ...[
            _StatusCard(
              status: _status,
              subtitle: _subtitle,
              score: score,
            ),
            const SizedBox(height: 16),

            Text('Detailed AI analysis',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),

            _AnalysisCard(
              title: 'Positive trends',
              description:
                  "Your baby's vital signs have been stable recently. No anomaly detected.",
              items: _insights,
            ),
            const SizedBox(height: 16),

            Text('Context factors',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),

            _ContextFactorsCard(
              dataQuality: _dataQuality,
              monitoringDuration: _monitoringDuration,
              aiReliability: _aiReliability,
            ),
            const SizedBox(height: 16),

            Text('Recommendations',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),

            _RecommendationsCard(items: _recommendations),
          ],
        ],
      ),
    );
  }
}

/* ---------------- UI Components ---------------- */

class _FormCard extends StatelessWidget {
  final TextEditingController deviceId;
  final TextEditingController hourEnd;
  final TextEditingController expectedSamples;
  final TextEditingController gestWeeks;
  final TextEditingController ageDays;
  final TextEditingController weightKg;

  final int gender;
  final ValueChanged<int> onGenderChanged;
  final VoidCallback? onPredict;

  const _FormCard({
    required this.deviceId,
    required this.hourEnd,
    required this.expectedSamples,
    required this.gestWeeks,
    required this.ageDays,
    required this.weightKg,
    required this.gender,
    required this.onGenderChanged,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    InputDecoration deco(String label, IconData icon) => InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        );

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(controller: deviceId, decoration: deco('Device ID', Icons.sensors_outlined)),
            const SizedBox(height: 12),
            TextField(
              controller: hourEnd,
              decoration: deco('hourEnd (ISO)', Icons.schedule_outlined),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expectedSamples,
                    keyboardType: TextInputType.number,
                    decoration: deco('Expected samples', Icons.data_usage_outlined),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: gender,
                    decoration: deco('Gender', Icons.wc_outlined),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('0')),
                      DropdownMenuItem(value: 1, child: Text('1')),
                    ],
                    onChanged: (v) => onGenderChanged(v ?? 1),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: gestWeeks,
                    keyboardType: TextInputType.number,
                    decoration: deco('Gestational age (weeks)', Icons.calendar_month_outlined),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: ageDays,
                    keyboardType: TextInputType.number,
                    decoration: deco('Age (days)', Icons.child_care_outlined),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            TextField(
              controller: weightKg,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: deco('Weight (kg)', Icons.monitor_weight_outlined),
            ),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: onPredict,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Predict health score'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String status;
  final String subtitle;
  final double score;

  const _StatusCard({
    required this.status,
    required this.subtitle,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = (score.clamp(0, 100)) / 100.0;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              child: Icon(Icons.check, color: theme.colorScheme.primary, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: normalized,
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${score.toStringAsFixed(0)}/100",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final String description;
  final List<_InsightItem> items;

  const _AnalysisCard({
    required this.title,
    required this.description,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Icon(Icons.trending_up, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(description, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 12),
            for (final it in items) ...[
              _InsightRow(item: it),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final _InsightItem item;
  const _InsightRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(item.title, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            children: [
              Icon(Icons.check, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(item.status, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        )
      ],
    );
  }
}

class _ContextFactorsCard extends StatelessWidget {
  final String dataQuality;
  final String monitoringDuration;
  final double aiReliability;

  const _ContextFactorsCard({
    required this.dataQuality,
    required this.monitoringDuration,
    required this.aiReliability,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relPct = (aiReliability.clamp(0, 1) * 100).toStringAsFixed(0);

    Widget row(String left, String right, {bool info = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(left, style: theme.textTheme.bodyMedium)),
            Row(
              children: [
                Text(right, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900)),
                if (info) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                ]
              ],
            )
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row('Data quality', dataQuality),
            const Divider(height: 1),
            row('Monitoring duration', monitoringDuration),
            const Divider(height: 1),
            row('AI reliability', '$relPct%', info: true),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  final List<String> items;
  const _RecommendationsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Text('Non-medical advice',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
            for (final r in items) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(r, style: theme.textTheme.bodyMedium)),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onErrorContainer),
        ),
      ),
    );
  }
}

class _InsightItem {
  final String title;
  final String status;
  const _InsightItem(this.title, this.status);
}
