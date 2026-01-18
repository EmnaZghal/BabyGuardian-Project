import 'package:flutter/material.dart';

class DotListItem extends StatelessWidget {
  final String text;
  final Color bulletColor;
  final Color textColor;

  const DotListItem(
    this.text, {
    super.key,
    this.bulletColor = const Color(0xFF1D4ED8),
    this.textColor = const Color(0xFF1E40AF),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(color: bulletColor, fontWeight: FontWeight.w900),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
