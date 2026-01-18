import 'package:flutter/material.dart';

enum AlertType { health, device }
enum AlertSeverity { low, medium, high }

class AlertItem {
  final int id;
  final AlertType type;
  final AlertSeverity severity;

  final String title;
  final String message;
  final String timeLabel;

  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  final bool read;

  const AlertItem({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.read,
  });
}
