import 'package:flutter/material.dart';

class GuideDots extends StatelessWidget {
  final int count;
  final int index;

  const GuideDots({
    super.key,
    required this.count,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 18 : 8,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEC4899) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
