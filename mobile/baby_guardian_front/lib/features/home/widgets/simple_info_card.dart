import 'package:flutter/material.dart';
import 'gradient_text.dart';

class SimpleInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final IconData icon;
  final LinearGradient gradient; // used for icon + value gradient, NOT for card bg
  final VoidCallback onTap;

  const SimpleInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFE5E7EB); // gray-200
    const textMuted = Color(0xFF6B7280); // gray-500

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
        child: Row(
          children: [
            // Icon stays colored
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
              child: Icon(icon, color: Colors.white, size: 26),
            ),

            const SizedBox(width: 12),

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
                    children: [
                      GradientText(
                        value,
                        gradient: LinearGradient(
                          colors: [gradient.colors.last, gradient.colors.first],
                        ),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        suffix,
                        style: const TextStyle(
                          fontSize: 13,
                          color: textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 22),
          ],
        ),
      ),
    );
  }
}
