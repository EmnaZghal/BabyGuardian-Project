import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';
import '../models/risk_item.dart';

class RiskItemCard extends StatelessWidget {
  final RiskItem risk;
  final VoidCallback? onTap;

  const RiskItemCard({
    super.key,
    required this.risk,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _levelColors(risk.level);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.bg,
              shape: BoxShape.circle,
            ),
            child: Icon(risk.icon, color: colors.fg, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        risk.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 22),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    risk.description,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: risk.score / 100.0,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation(colors.bar),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _PercentBadge(
                      text: '${risk.score}%',
                      bg: colors.badgeBg,
                      fg: colors.badgeFg,
                      border: colors.badgeBorder,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final Color border;

  const _PercentBadge({
    required this.text,
    required this.bg,
    required this.fg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _LevelPalette {
  final Color bg, fg, bar, badgeBg, badgeFg, badgeBorder;
  const _LevelPalette({
    required this.bg,
    required this.fg,
    required this.bar,
    required this.badgeBg,
    required this.badgeFg,
    required this.badgeBorder,
  });
}

_LevelPalette _levelColors(RiskLevel level) {
  switch (level) {
    case RiskLevel.medium:
      return const _LevelPalette(
        bg: Color(0xFFFFEDD5), // orange-100
        fg: Color(0xFFEA580C), // orange-600
        bar: Color(0xFFF97316), // orange-500
        badgeBg: Color(0xFFFFEDD5),
        badgeFg: Color(0xFF9A3412),
        badgeBorder: Color(0xFFFED7AA),
      );
    case RiskLevel.high:
      return const _LevelPalette(
        bg: Color(0xFFFEE2E2), // red-100
        fg: Color(0xFFDC2626), // red-600
        bar: Color(0xFFEF4444), // red-500
        badgeBg: Color(0xFFFEE2E2),
        badgeFg: Color(0xFF991B1B),
        badgeBorder: Color(0xFFFECACA),
      );
    case RiskLevel.low:
    default:
      return const _LevelPalette(
        bg: Color(0xFFDCFCE7), // green-100
        fg: Color(0xFF16A34A), // green-600
        bar: Color(0xFF22C55E), // green-500
        badgeBg: Color(0xFFDCFCE7),
        badgeFg: Color(0xFF15803D),
        badgeBorder: Color(0xFFBBF7D0),
      );
  }
}
