import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';

class HealthGlobalStatusCard extends StatelessWidget {
  final String babyName;
  final int score; // out of 100

  const HealthGlobalStatusCard({
    super.key,
    required this.babyName,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF86EFAC)), // green-300
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFECFDF5), // green-50
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E), // green-500
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Normal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Everything is fine for $babyName',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Health score',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$score/100',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: score / 100.0,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF22C55E)),
            ),
          ),
        ],
      ),
    );
  }
}
