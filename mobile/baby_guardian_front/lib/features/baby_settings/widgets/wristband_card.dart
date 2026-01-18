import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';
import 'pill_badge.dart';

class WristbandCard extends StatelessWidget {
  const WristbandCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'BabyGuardian BR-001',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: BG-2025-EMM-001',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const PillBadge(
                text: 'Connected',
                bgColor: Color(0xFFDCFCE7),
                borderColor: Color(0xFFBBF7D0),
                textColor: Color(0xFF15803D),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _MiniRow(
                  icon: Icons.battery_full,
                  text: '87% battery',
                ),
              ),
              Expanded(
                child: _MiniRow(
                  icon: Icons.wifi,
                  text: 'Strong signal',
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF22C55E)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
