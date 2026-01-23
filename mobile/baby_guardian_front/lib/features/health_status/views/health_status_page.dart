import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/health_status_service.dart';
import '../model/health_status_result.dart';
import '../widgets/health_global_status_card.dart';
import '../widgets/health_ai_analysis_card.dart';
import '../widgets/health_context_factors_card.dart';
import '../widgets/health_recommendations_card.dart';

class HealthStatusPage extends StatefulWidget {
  const HealthStatusPage({super.key});

  @override
  State<HealthStatusPage> createState() => _HealthStatusPageState();
}

class _HealthStatusPageState extends State<HealthStatusPage> {
  // ✅ لا late ولا initState assign => مافي bug
  final HealthStatusService _svc = HealthStatusService();

  // Inputs
  final _deviceId = TextEditingController(text: 'esp32-c00aa81f8a3c');
  final _expectedSamples = TextEditingController(text: '12');
  final _gestAge = TextEditingController(text: '38');
  final _gender = ValueNotifier<int>(1);
  final _ageDays = TextEditingController(text: '10');
  final _weightKg = TextEditingController(text: '3.2');

  bool _loading = false;
  String? _error;
  HealthStatusResult? _result;

  @override
  void dispose() {
    _svc.dispose();
    _deviceId.dispose();
    _expectedSamples.dispose();
    _gestAge.dispose();
    _ageDays.dispose();
    _weightKg.dispose();
    _gender.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final res = await _svc.predictHealthScoreHourly(
        deviceId: _deviceId.text.trim(),
        hourEnd: DateTime.now(),
        expectedSamples: int.parse(_expectedSamples.text.trim()),
        gestationalAgeWeeks: int.parse(_gestAge.text.trim()),
        gender: _gender.value,
        ageDays: int.parse(_ageDays.text.trim()),
        weightKg: double.parse(_weightKg.text.trim()),
      );

      setState(() {
        _result = HealthStatusResult.fromJson(res);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

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
        title: const Text('Health status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Info"),
                  content: const Text(
                    "This page shows an AI health score. It is not a medical diagnosis.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InputsCard(
            deviceId: _deviceId,
            expectedSamples: _expectedSamples,
            gestAge: _gestAge,
            gender: _gender,
            ageDays: _ageDays,
            weightKg: _weightKg,
            loading: _loading,
            onRun: _run,
          ),
          const SizedBox(height: 14),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            ),

          if (_error != null) _ErrorBanner(message: _error!),

          if (!_loading && _error == null && result != null) ...[
            HealthGlobalStatusCard(
              statusTitle: result.statusTitle,
              statusSubtitle: result.statusSubtitle,
              score: result.score,
            ),
            const SizedBox(height: 14),

            Text(
              'Detailed AI analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            HealthAiAnalysisCard(
              title: result.analysisTitle,
              description: result.analysisDescription,
              bullets: result.bullets,
            ),

            const SizedBox(height: 14),
            Text(
              'Context factors',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            HealthContextFactorsCard(
              items: {'Data quality': result.dataQuality},
              monitoringDays: result.monitoringDays,
              aiReliability: result.aiReliability,
            ),

            const SizedBox(height: 14),
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            HealthRecommendationsCard(items: result.recommendations),
          ],
        ],
      ),
    );
  }
}

class _InputsCard extends StatelessWidget {
  final TextEditingController deviceId;
  final TextEditingController expectedSamples;
  final TextEditingController gestAge;
  final ValueNotifier<int> gender;
  final TextEditingController ageDays;
  final TextEditingController weightKg;
  final bool loading;
  final VoidCallback onRun;

  const _InputsCard({
    required this.deviceId,
    required this.expectedSamples,
    required this.gestAge,
    required this.gender,
    required this.ageDays,
    required this.weightKg,
    required this.loading,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Input', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),

            TextField(
              controller: deviceId,
              decoration: const InputDecoration(
                labelText: 'Device ID',
                prefixIcon: Icon(Icons.sensors),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expectedSamples,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Expected samples',
                      prefixIcon: Icon(Icons.timeline),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: gestAge,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Gestational age (weeks)',
                      prefixIcon: Icon(Icons.calendar_month),
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
                    controller: ageDays,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Baby age (days)',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: weightKg,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ValueListenableBuilder<int>(
              valueListenable: gender,
              builder: (_, v, __) {
                return DropdownButtonFormField<int>(
                  value: v,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('0')),
                    DropdownMenuItem(value: 1, child: Text('1')),
                  ],
                  onChanged: loading ? null : (x) => gender.value = x ?? 1,
                );
              },
            ),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loading ? null : onRun,
                icon: const Icon(Icons.health_and_safety_outlined),
                label: const Text('Run Health Score'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: cs.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
