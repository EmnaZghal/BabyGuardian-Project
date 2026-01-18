import 'package:flutter/material.dart';
import 'app_card.dart';

class DisclaimerCard extends StatelessWidget {
  final String title;
  final String message;

  const DisclaimerCard({
    super.key,
    this.title = 'Important',
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8), // yellow-50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)), // yellow-200
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFCA8A04)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.35,
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
