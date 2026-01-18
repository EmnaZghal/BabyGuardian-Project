import 'package:flutter/material.dart';

class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          trailing!,
        ],
      ],
    );
  }
}
