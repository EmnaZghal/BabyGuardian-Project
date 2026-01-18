import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool trailingLive;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailingLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (trailingLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F9EF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "Live",
                  style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
