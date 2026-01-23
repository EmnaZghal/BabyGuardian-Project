import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/predictions_service.dart';
import '../widgets/overall_status_card.dart';
import '../widgets/risk_item_card.dart';
import '../models/risk_item.dart';

class PredictionsPage extends StatefulWidget {
  const PredictionsPage({super.key});

  @override
  State<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends State<PredictionsPage> {
  final _svc = PredictionsService();

  final _deviceId = TextEditingController(text: 'esp32-c00aa81f8a3c');
  final _subjectId = TextEditingController(text: '1');
  final _age = TextEditingController(text: '30');
  final _sexBin = ValueNotifier<int>(1); // 1=male? (selon ton dataset)
  final _height = TextEditingController(text: '177');
  final _weight = TextEditingController(text: '94');

  bool _loading = false;
  String? _error;

  Map<String, dynamic>? _raw;
  List<RiskItem> _risks = [];
  String? _statusText;
  double? _overallScore;

  // ✅ uniquement les valeurs prédites
  double? _predTemp;
  double? _predSpo2;
  double? _predHr;

  @override
  void dispose() {
    _svc.dispose();
    _deviceId.dispose();
    _subjectId.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _sexBin.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    setState(() {
      _loading = true;
      _error = null;
      _raw = null;
      _risks = [];
      _statusText = null;
      _overallScore = null;

      _predTemp = null;
      _predSpo2 = null;
      _predHr = null;
    });

    try {
      final res = await _svc.predictHourly(
        deviceId: _deviceId.text.trim(),
        subjectId: int.parse(_subjectId.text.trim()),
        hourTs: DateTime.now(),
        age: int.parse(_age.text.trim()),
        sexBin: _sexBin.value,
        heightCm: int.parse(_height.text.trim()),
        weightKg: int.parse(_weight.text.trim()),
      );

      final overallScore = _toDouble(
        res['overallScore'] ?? res['score'] ?? res['riskScore'],
      );
      final status = (res['status'] ?? res['level'] ?? res['message'])
          ?.toString();

      final risksJson = res['risks'] ?? res['items'] ?? res['details'];
      final risks = <RiskItem>[];
      if (risksJson is List) {
        for (final e in risksJson) {
          if (e is Map<String, dynamic>) risks.add(RiskItem.fromJson(e));
          if (e is Map)
            risks.add(RiskItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }

      // ✅ backend actuel: res['pred'] => { temp_1h, spo2_1h, hr_1h }
      final pred = res['pred'];
      double? pTemp;
      double? pSpo2;
      double? pHr;
      if (pred is Map) {
        final m = Map<String, dynamic>.from(pred);
        pTemp = _toDouble(m['temp_1h'] ?? m['temp']);
        pSpo2 = _toDouble(m['spo2_1h'] ?? m['spo2']);
        pHr = _toDouble(m['hr_1h'] ?? m['hr'] ?? m['heart_rate']);
      }

      setState(() {
        _raw = res;
        _overallScore = overallScore;
        _statusText = status;
        _risks = risks;

        _predTemp = pTemp;
        _predSpo2 = pSpo2;
        _predHr = pHr;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  String _fmt(double? v, {int digits = 1}) {
    if (v == null) return '--';
    return v.toStringAsFixed(digits);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Retour...')));
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          tooltip: 'Back',
        ),
        title: const Text('Predict Vitals'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _FormCard(
            deviceId: _deviceId,
            subjectId: _subjectId,
            age: _age,
            height: _height,
            weight: _weight,
            sexBin: _sexBin,
            onPredict: _loading ? null : _predict,
          ),
          const SizedBox(height: 12),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),

          if (_error != null) _ErrorCard(message: _error!),

          if (_raw != null) ...[
            OverallStatusCard(
              statusText: _statusText ?? 'OK',
              overallScore: _overallScore,
              title: 'Résultat global',
              subtitle: 'Prédiction sur 1h',
            ),
            const SizedBox(height: 12),

            // ✅ UI PRO : afficher seulement les valeurs prédictes
            _PredictedVitalsCard(temp: _predTemp, spo2: _predSpo2, hr: _predHr),
            const SizedBox(height: 12),

            // Si tu veux garder risks quand ils existent, sinon rien (pas de Raw JSON)
            if (_risks.isNotEmpty) ...[
              Text(
                'Risks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final r in _risks) ...[
                RiskItemCard(item: r),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _PredictedVitalsCard extends StatelessWidget {
  final double? temp;
  final double? spo2;
  final double? hr;

  const _PredictedVitalsCard({
    required this.temp,
    required this.spo2,
    required this.hr,
  });

  String _fmt(double? v, {int digits = 1}) {
    if (v == null) return '--';
    return v.toStringAsFixed(digits);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  child: Icon(
                    Icons.auto_graph_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Valeurs prédites (1h)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _VitalTile(
                    title: 'Température',
                    value: _fmt(temp, digits: 1),
                    unit: '°C',
                    icon: Icons.thermostat_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _VitalTile(
                    title: 'SpO₂',
                    value: _fmt(spo2, digits: 0),
                    unit: '%',
                    icon: Icons.monitor_heart_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _VitalTile(
                    title: 'Heart rate',
                    value: _fmt(hr, digits: 0),
                    unit: 'bpm',
                    icon: Icons.favorite_border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Astuce: si tu veux afficher plus tard des “features” ou un mini graphique, on peut ajouter un bouton “Détails”.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;

  const _VitalTile({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController deviceId;
  final TextEditingController subjectId;
  final TextEditingController age;
  final TextEditingController height;
  final TextEditingController weight;
  final ValueNotifier<int> sexBin;
  final VoidCallback? onPredict;

  const _FormCard({
    required this.deviceId,
    required this.subjectId,
    required this.age,
    required this.height,
    required this.weight,
    required this.sexBin,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    InputDecoration deco(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: deviceId,
              decoration: deco('deviceId', Icons.sensors_outlined),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subjectId,
              keyboardType: TextInputType.number,
              decoration: deco('subjectId', Icons.badge_outlined),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: age,
                    keyboardType: TextInputType.number,
                    decoration: deco('age', Icons.cake_outlined),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: sexBin,
                    builder: (_, v, __) => DropdownButtonFormField<int>(
                      value: v,
                      decoration: deco('sexBin', Icons.wc_outlined),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('0')),
                        DropdownMenuItem(value: 1, child: Text('1')),
                      ],
                      onChanged: (x) => sexBin.value = x ?? 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: height,
                    keyboardType: TextInputType.number,
                    decoration: deco('heightCm', Icons.height_outlined),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: weight,
                    keyboardType: TextInputType.number,
                    decoration: deco('weightKg', Icons.monitor_weight_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: onPredict,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Predict'),
              ),
            ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// (optionnel) tu peux supprimer cette classe si tu ne l’utilises plus
class _RawJsonCard extends StatelessWidget {
  final Map<String, dynamic> json;
  const _RawJsonCard({required this.json});

  @override
  Widget build(BuildContext context) {
    final pretty = const JsonEncoder.withIndent('  ').convert(json);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SelectableText(pretty),
      ),
    );
  }
}
