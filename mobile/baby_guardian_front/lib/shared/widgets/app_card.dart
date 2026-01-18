import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BoxDecoration? decoration;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.decoration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5E7EB)), // gray-200
      boxShadow: const [
        BoxShadow(
          blurRadius: 16,
          color: Color(0x0F000000),
          offset: Offset(0, 10),
        )
      ],
    );

    final content = Container(
      padding: padding,
      decoration: decoration ?? defaultDecoration,
      child: child,
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: content,
    );
  }
}
