import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF6B7280), // gray-500
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }
}
