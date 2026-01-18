import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';

class VitalMiniCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final List<Color> gradientColors;

  final String value;
  final String label;

  const VitalMiniCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.gradientColors,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            color: Color(0x0F000000),
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
