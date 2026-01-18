import 'package:flutter/material.dart';
import 'status_badge.dart';

class BulletStatusRow extends StatelessWidget {
  final String label;
  final String badgeText;

  const BulletStatusRow({
    super.key,
    required this.label,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF22C55E),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        StatusBadge(text: badgeText),
      ],
    );
  }
}
