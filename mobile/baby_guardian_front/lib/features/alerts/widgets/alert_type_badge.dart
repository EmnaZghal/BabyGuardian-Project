import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/pill_badge.dart';
import '../models/alert_item.dart';

class AlertTypeBadge extends StatelessWidget {
  final AlertType type;

  const AlertTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == AlertType.health) {
      return const PillBadge(
        text: 'Health',
        bgColor: Color(0xFFFFEDD5),    // orange-100
        textColor: Color(0xFF9A3412),  // orange-800
        borderColor: Color(0xFFFED7AA),// orange-200
      );
    }
    return const PillBadge(
      text: 'Device',
      bgColor: Color(0xFFDBEAFE),     // blue-100
      textColor: Color(0xFF1D4ED8),   // blue-700
      borderColor: Color(0xFFBFDBFE), // blue-200
    );
  }
}
