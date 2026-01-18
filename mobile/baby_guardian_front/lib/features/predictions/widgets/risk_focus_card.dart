import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';

class RiskFocusCard extends StatelessWidget {
  final String title;
  final int score;
  final List<String> factors;
  final String trendText;
  final int reliability;

  const RiskFocusCard({
    super.key,
    required this.title,
    required this.score,
    required this.factors,
    required this.trendText,
    required this.reliability,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // score
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Risk score',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '$score%',
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
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
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF22C55E)),
            ),
          ),

          const SizedBox(height: 16),

          // factors
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Analyzed factors',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...factors.map((f) => _Bullet(f)),

          const SizedBox(height: 14),

          // trend
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Trends (24h)',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 18, color: Color(0xFF22C55E)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trendText,
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // reliability badge full width
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE), // blue-100
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)), // blue-200
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 18, color: Color(0xFF1D4ED8)),
                const SizedBox(width: 8),
                Text(
                  'Prediction reliability: $reliability%',
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontWeight: FontWeight.w900)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
