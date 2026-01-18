import 'package:flutter/material.dart';
import 'gradient_text.dart';
import 'pulse_icon.dart';

class VitalCard extends StatelessWidget {
  final String title;
  final String valueText;
  final String unitBadge;
  final String statusText;
  final String? suffix;
  final LinearGradient gradient; // used for icon + value gradient, NOT for card bg
  final IconData icon;
  final Widget sparkline;
  final VoidCallback onTap;
  final bool animatePulseIcon;

  const VitalCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.unitBadge,
    required this.statusText,
    required this.gradient,
    required this.icon,
    required this.sparkline,
    required this.onTap,
    this.suffix,
    this.animatePulseIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFE5E7EB); // gray-200
    const textMuted = Color(0xFF6B7280); // gray-500
    const textDark = Color(0xFF111827); // gray-900

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, // ✅ WHITE background
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              color: Color(0x14000000),
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon block stays colored
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: gradient, // ✅ keep icon color
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 14,
                            color: gradient.colors.first.withOpacity(0.22),
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Center(
                        child: PulseIcon(
                          enabled: animatePulseIcon,
                          child: Icon(icon, color: Colors.white, size: 26),
                        ),
                      ),
                    ),

                    // Unit badge
                    Positioned(
                      bottom: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 10,
                              color: Color(0x22000000),
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          unitBadge,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GradientText(
                            valueText,
                            gradient: LinearGradient(
                              colors: [gradient.colors.last, gradient.colors.first],
                            ),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (suffix != null) ...[
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                suffix!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Status + chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F9EF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        size: 14,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 22),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            sparkline,
          ],
        ),
      ),
    );
  }
}
