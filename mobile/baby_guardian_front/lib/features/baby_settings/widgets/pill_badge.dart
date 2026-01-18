import 'package:flutter/material.dart';

class PillBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  const PillBadge({
    super.key,
    required this.text,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
