import 'package:flutter/material.dart';
import 'quick_action_tile.dart';

class AssistantQuickAction {
  final String title;
  final String subtitle;
  final String intent;
  final String message;
  final IconData icon;

  const AssistantQuickAction({
    required this.title,
    required this.subtitle,
    required this.intent,
    required this.message,
    required this.icon,
  });
}

class AssistantQuickActionTile extends StatelessWidget {
  final AssistantQuickAction action;
  final VoidCallback onTap;

  const AssistantQuickActionTile({
    super.key,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return QuickActionTile(
      title: action.title,
      subtitle: action.subtitle,
      icon: action.icon,
      onTap: onTap,
    );
  }
}
