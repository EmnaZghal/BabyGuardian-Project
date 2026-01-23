import 'package:flutter/material.dart';

class AssistantAvatar extends StatelessWidget {
  final double size;
  const AssistantAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.smart_toy_outlined,
          color: theme.colorScheme.onPrimary,
          size: size * 0.55,
        ),
      ),
    );
  }
}
