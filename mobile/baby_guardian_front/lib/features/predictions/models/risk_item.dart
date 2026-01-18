import 'package:flutter/material.dart';

enum RiskLevel { low, medium, high }

class RiskItem {
  final String id;
  final String title;
  final String description;
  final int score; // 0..100
  final IconData icon;
  final RiskLevel level;

  const RiskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.score,
    required this.icon,
    this.level = RiskLevel.low,
  });
}
