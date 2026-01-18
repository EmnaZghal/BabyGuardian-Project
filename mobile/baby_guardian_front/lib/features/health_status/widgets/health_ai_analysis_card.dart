import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';
import 'package:baby_guardian_front/shared/widgets/bullet_status_row.dart';

class HealthAiAnalysisCard extends StatelessWidget {
  final String babyName;

  const HealthAiAnalysisCard({
    super.key,
    required this.babyName,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE), // blue-100
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.trending_up, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Positive trends',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$babyName's vital signs have been stable for the last 24 hours. No anomaly detected.",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const BulletStatusRow(label: 'Stable temperature', badgeText: 'Normal'),
          const SizedBox(height: 10),
          const BulletStatusRow(label: 'Optimal SpO₂', badgeText: 'Normal'),
          const SizedBox(height: 10),
          const BulletStatusRow(label: 'Regular heart rate', badgeText: 'Normal'),
        ],
      ),
    );
  }
}
