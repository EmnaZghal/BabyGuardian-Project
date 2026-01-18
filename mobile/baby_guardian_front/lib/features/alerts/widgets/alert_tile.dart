import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';
import '../models/alert_item.dart';
import 'alert_type_badge.dart';

class AlertTile extends StatelessWidget {
  final AlertItem alert;
  final VoidCallback? onTap;

  const AlertTile({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = alert.read ? const Color(0xFFF9FAFB) : Colors.white; // gray-50 / white

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            color: Color(0x0F000000),
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon bubble
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: alert.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(alert.icon, color: alert.iconColor, size: 22),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alert.timeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                AlertTypeBadge(type: alert.type),
              ],
            ),
          ),

          const SizedBox(width: 10),
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 22),
          ),
        ],
      ),
    );
  }
}
