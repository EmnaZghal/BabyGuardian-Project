import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.text,
    this.icon = Icons.check_circle,
    this.bgColor = const Color(0xFFDCFCE7), // green-100
    this.borderColor = const Color(0xFFBBF7D0), // green-200
    this.iconColor = const Color(0xFF16A34A), // green-600
    this.textColor = const Color(0xFF15803D), // green-700
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
