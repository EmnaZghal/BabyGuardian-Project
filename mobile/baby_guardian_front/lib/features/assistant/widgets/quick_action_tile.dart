import 'package:flutter/material.dart';

class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;

  final Color bg;
  final Color border;
  final Color iconBg;
  final Color iconColor;

  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
