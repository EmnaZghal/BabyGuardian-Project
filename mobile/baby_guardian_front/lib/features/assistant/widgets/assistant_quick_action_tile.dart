import 'package:flutter/material.dart';

class AssistantQuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const AssistantQuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.iconBgColor,
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
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),

            // ✅ Important : éviter overflow texte
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
