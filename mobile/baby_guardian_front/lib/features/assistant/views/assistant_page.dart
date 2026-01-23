import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/assistant_service.dart';
import '../widgets/assistant_avatar.dart';
import '../widgets/assistant_quick_action_tile.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../../../cores/constants/env.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  late final AssistantService _service;

  final List<ChatMessage> _messages = [];
  final ScrollController _scroll = ScrollController();

  String _babyId = 'b123'; // tu peux le rendre dynamique
  bool _sending = false;

  final quickActions = const [
    AssistantQuickAction(
      title: 'SpO2',
      subtitle: 'Définition et valeurs normales',
      intent: 'DEFINE_SPO2',
      message: 'Que signifie SpO2 ?',
      icon: Icons.monitor_heart_outlined,
    ),
    AssistantQuickAction(
      title: 'Température',
      subtitle: 'Fièvre, seuils, conseils',
      intent: 'DEFINE_TEMPERATURE',
      message: 'Quelle est la température normale pour un bébé ?',
      icon: Icons.thermostat_outlined,
    ),
    AssistantQuickAction(
      title: 'Fréquence cardiaque',
      subtitle: 'Valeurs normales',
      intent: 'DEFINE_HEART_RATE',
      message: 'Quelle est la fréquence cardiaque normale pour un bébé ?',
      icon: Icons.favorite_border,
    ),
    AssistantQuickAction(
      title: 'Alerte',
      subtitle: 'Que faire en cas d’alerte ?',
      intent: 'ALERT_GUIDE',
      message: 'Que dois-je faire si je reçois une alerte ?',
      icon: Icons.warning_amber_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // ✅ Utilise Env.gatewayBaseUrl (cloudflare / ip)
    _service = AssistantService(baseUrl: Env.gatewayBaseUrl);

    _messages.add(ChatMessage(
      id: 'welcome',
      role: ChatRole.assistant,
      text:
          "Bonjour 👋 Je suis l’assistant BabyGuardian.\n"
          "Pose-moi une question (SpO2, température, alertes…) ou utilise les actions rapides.",
      createdAt: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _service.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send({
    required String text,
    String? intent,
  }) async {
    final msg = text.trim();
    if (msg.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _messages.add(ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: ChatRole.user,
        text: msg,
        createdAt: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        id: 'loading',
        role: ChatRole.assistant,
        text: '…',
        createdAt: DateTime.now(),
        isLoading: true,
      ));
    });

    _scrollToBottom();

    try {
      final reply = await _service.sendMessage(
        message: msg,
        babyId: _babyId,
        intent: intent,
      );

      setState(() {
        _messages.removeWhere((m) => m.id == 'loading' && m.isLoading);
        _messages.add(ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          role: ChatRole.assistant,
          text: reply.isEmpty ? "Je n’ai pas reçu de réponse." : reply,
          createdAt: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.id == 'loading' && m.isLoading);
        _messages.add(ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          role: ChatRole.assistant,
          text: "Erreur: $e",
          createdAt: DateTime.now(),
        ));
      });
    } finally {
      setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const AssistantAvatar(size: 34),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'BabyGuardian',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Changer babyId',
            icon: const Icon(Icons.badge_outlined),
            onPressed: () async {
              final controller = TextEditingController(text: _babyId);
              final newId = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Baby ID'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'ex: b123',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () =>
                          Navigator.pop(ctx, controller.text.trim()),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );

              if (newId != null && newId.isNotEmpty) {
                setState(() => _babyId = newId);
              }
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 108,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              scrollDirection: Axis.horizontal,
              itemCount: quickActions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final a = quickActions[i];
                return AssistantQuickActionTile(
                  action: a,
                  onTap: () => _send(text: a.message, intent: a.intent),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => ChatBubble(message: _messages[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: ChatInputBar(
              enabled: !_sending,
              onSend: (text) => _send(text: text),
            ),
          ),
        ],
      ),
    );
  }
}
