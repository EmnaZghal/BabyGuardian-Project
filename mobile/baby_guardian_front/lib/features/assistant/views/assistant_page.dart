import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/section_title.dart';
import 'package:baby_guardian_front/shared/widgets/disclaimer_card.dart';

import '../models/chat_message.dart';
import '../widgets/assistant_avatar.dart';
import '../widgets/assistant_quick_action_tile.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final List<ChatMessage> _messages = [
    const ChatMessage(
      id: 1,
      type: MessageType.assistant,
      content: "Hi! I'm your BabyGuardian assistant. How can I help you today?",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send([String? text]) {
    final raw = (text ?? _controller.text).trim();
    if (raw.isEmpty) return;

    final nextId = _messages.isEmpty ? 1 : _messages.last.id + 1;

    setState(() {
      _messages.add(ChatMessage(id: nextId, type: MessageType.user, content: raw));
      _messages.add(ChatMessage(
        id: nextId + 1,
        type: MessageType.assistant,
        content:
            "Thanks for your question. Emma's health status is currently normal. "
            "All vital signs are within expected ranges for a 3-month-old baby.",
      ));
    });

    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF111827);
    const textMuted = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Colors.white],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ===== Header =====
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14,
                      color: Color(0x14000000),
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.smart_toy_outlined, color: Color(0xFF111827)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assistant',
                            style: TextStyle(
                              color: textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'RAG chatbot — support & tips',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===== Content (scrollable) =====
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  children: [
                    // Quick actions
                    const SectionTitle('Quick questions'),
                    const SizedBox(height: 10),

                    AssistantQuickActionTile(
                      icon: Icons.info_outline,
                      label: 'Explain the last alert',
                      bgColor: const Color(0xFFEFF6FF),
                      borderColor: const Color(0xFFDBEAFE),
                      iconBgColor: const Color(0xFFDBEAFE),
                      iconColor: const Color(0xFF3B82F6),
                      onTap: () => _send('Explain the last alert'),
                    ),
                    const SizedBox(height: 10),

                    AssistantQuickActionTile(
                      icon: Icons.trending_up,
                      label: "What's the current health status?",
                      bgColor: const Color(0xFFECFDF5),
                      borderColor: const Color(0xFFBBF7D0),
                      iconBgColor: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF16A34A),
                      onTap: () => _send("What's the current health status?"),
                    ),
                    const SizedBox(height: 10),

                    AssistantQuickActionTile(
                      icon: Icons.monitor_heart_outlined,
                      label: 'What does SpO₂ mean?',
                      bgColor: const Color(0xFFECFEFF),
                      borderColor: const Color(0xFFCFFAFE),
                      iconBgColor: const Color(0xFFCFFAFE),
                      iconColor: const Color(0xFF0891B2),
                      onTap: () => _send('What does SpO₂ mean?'),
                    ),

                    const SizedBox(height: 18),

                    // Messages
                    ..._messages.map(_buildMessageRow).toList(),

                    const SizedBox(height: 18),

                    // Disclaimer (shared widget)
                    const DisclaimerCard(
                      title: 'Warning',
                      message:
                          'This assistant provides general information. If you have concerns about your baby’s health, please consult a healthcare professional.',
                    ),

                    const SizedBox(height: 90), // espace pour l'input
                  ],
                ),
              ),

              // ===== Input bar =====
              ChatInputBar(
                controller: _controller,
                onSend: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIX OVERFLOW ICI : Avatar + bubble => Flexible + Align + maxWidth %
  Widget _buildMessageRow(ChatMessage m) {
    final isUser = m.type == MessageType.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const AssistantAvatar(),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: ChatBubble(message: m),
            ),
          ),
        ],
      ),
    );
  }
}
