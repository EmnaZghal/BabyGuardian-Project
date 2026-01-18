import 'package:flutter/material.dart';
import 'app_card.dart';
import 'dot_list_item.dart';

class RecommendationsCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const RecommendationsCard({
    super.key,
    this.title = 'Non-medical advice',
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // blue-50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)), // blue-100
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: Color(0xFF3B82F6)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                for (final it in items) DotListItem(it),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
