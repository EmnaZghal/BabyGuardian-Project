import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/status_badge.dart';

class BabyProfileHeader extends StatelessWidget {
  final String name;
  final String statusText;

  const BabyProfileHeader({
    super.key,
    required this.name,
    this.statusText = 'Normal',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFBCFE8), // pink-200
                Color(0xFFF9A8D4), // pink-300
              ],
            ),
          ),
          child: const Icon(
            Icons.child_friendly,
            color: Colors.white,
            size: 52,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        const StatusBadge(text: 'Normal'), // ✅ vert
      ],
    );
  }
}
