import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final maxW = MediaQuery.of(context).size.width * 0.78; // ✅ au lieu de 320 fixe

    if (isUser) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF3B82F6), Color(0xFF22D3EE)],
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                color: Color(0x14000000),
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Text(
            message.content,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    // assistant bubble
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Text(
          message.content,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
