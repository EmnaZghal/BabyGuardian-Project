import 'package:flutter/material.dart';

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  final String title;
  final String? subtitle;

  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _IconCircle(icon: icon, bg: iconBg, color: iconColor),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;

  const _IconCircle({
    required this.icon,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
