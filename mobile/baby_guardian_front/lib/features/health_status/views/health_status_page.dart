import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/health_global_status_card.dart';
import '../widgets/health_ai_analysis_card.dart';
import '../widgets/health_context_factors_card.dart';

import 'package:baby_guardian_front/shared/widgets/recommendations_card.dart';
import 'package:baby_guardian_front/shared/widgets/disclaimer_card.dart';

class HealthStatusPage extends StatelessWidget {
  const HealthStatusPage({super.key});

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Info'),
        content: const Text(
          'This screen shows a summary of the baby health status and AI insights.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const babyName = "Emma";
    const score = 87;
    const aiReliability = 95;
    const monitoringDays = 7;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x14000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final r = GoRouter.of(context);
            if (r.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'Health status',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showInfo(context),
            icon: const Icon(Icons.info_outline),
            color: const Color(0xFF3B82F6),
            tooltip: 'Info',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFF6FF),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HealthGlobalStatusCard(babyName: babyName, score: score),

              const SizedBox(height: 18),
              const Text(
                'Detailed AI analysis',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              const HealthAiAnalysisCard(babyName: babyName),

              const SizedBox(height: 18),
              const Text(
                'Context factors',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              const HealthContextFactorsCard(
                monitoringDays: monitoringDays,
                aiReliability: aiReliability,
              ),

              const SizedBox(height: 18),
              const Text(
                'Recommendations',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              // ✅ Recommendations moved to shared/widgets
              const RecommendationsCard(
                items: [
                  'Keep regular monitoring',
                  'Keep the wristband well positioned',
                  'Make sure the wristband is charged',
                ],
              ),

              const SizedBox(height: 14),

              const DisclaimerCard(
                message:
                    'This information does not replace professional medical advice. If in doubt, consult your pediatrician.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
