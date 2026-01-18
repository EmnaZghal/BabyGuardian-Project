import 'package:flutter/material.dart';

class AssistantAvatar extends StatelessWidget {
  const AssistantAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF60A5FA), Color(0xFF22D3EE)], // blue -> cyan
        ),
      ),
      child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 16),
    );
  }
}
