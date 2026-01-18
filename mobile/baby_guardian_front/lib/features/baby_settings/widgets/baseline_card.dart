import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';
import 'pill_badge.dart';

class BaselineCard extends StatelessWidget {
  const BaselineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Baseline learning',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              PillBadge(
                text: 'Completed',
                bgColor: Color(0xFFDBEAFE),
                borderColor: Color(0xFFBFDBFE),
                textColor: Color(0xFF1D4ED8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "The wristband collected enough data to establish Emma's normal baseline values.",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              color: const Color(0xFFE5E7EB),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 1.0, // ✅ 100%
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF60A5FA), Color(0xFF22D3EE)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
