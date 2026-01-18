import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/risk_item.dart';
import '../widgets/overall_status_card.dart';
import '../widgets/risk_item_card.dart';
import '../widgets/risk_focus_card.dart';

import 'package:baby_guardian_front/shared/widgets/recommendations_card.dart';
import 'package:baby_guardian_front/shared/widgets/disclaimer_card.dart';

class PredictionsPage extends StatelessWidget {
  const PredictionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const risks = <RiskItem>[
      RiskItem(
        id: 'infection',
        title: 'Infection risk',
        description: 'Very low risk',
        score: 12,
        icon: Icons.error_outline,
        level: RiskLevel.low,
      ),
      RiskItem(
        id: 'fever',
        title: 'Fever risk',
        description: 'Stable temperature',
        score: 8,
        icon: Icons.thermostat,
        level: RiskLevel.low,
      ),
      RiskItem(
        id: 'hypoxia',
        title: 'Hypoxia risk',
        description: 'Optimal SpO₂',
        score: 5,
        icon: Icons.monitor_heart,
        level: RiskLevel.low,
      ),
      RiskItem(
        id: 'tachycardia',
        title: 'Tachycardia risk',
        description: 'Normal rhythm',
        score: 10,
        icon: Icons.favorite,
        level: RiskLevel.low,
      ),
    ];

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
              context.go('/home'); // fallback
            }
          },
        ),
        title: const Text(
          'Predictions',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),

      // ✅ No download button (no FAB)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFF6FF), // blue-50
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OverallStatusCard(
                title: 'No risk detected',
                subtitle: 'All indicators are green',
              ),

              const SizedBox(height: 18),

              const Text(
                'Risk analysis',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              ...risks.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RiskItemCard(
                    risk: r,
                    onTap: () {
                      // optional: you can navigate to a details page later
                      // e.g. context.go('/predictions/${r.id}');
                    },
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Focus: Infection risk",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              const RiskFocusCard(
                title: 'Infection risk',
                score: 12,
                reliability: 92,
                trendText: 'Stable — no degradation',
                factors: [
                  'Stable body temperature',
                  'Normal oxygen saturation',
                  'Regular heart rate',
                  'No abnormal variation detected',
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'Recommended actions',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              const RecommendationsCard(
                title: 'Non-medical advice',
                items: [
                  'Continue normal monitoring',
                  'Maintain good hygiene',
                  'Check the wristband regularly',
                ],
              ),

              const SizedBox(height: 14),

              const DisclaimerCard(
                title: 'Medical warning',
                message:
                    'These predictions are based on AI and do not constitute a medical diagnosis. Always consult a healthcare professional if in doubt.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
