import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardHeader extends StatelessWidget {
  final String babyName;
  final String subtitle;

  const DashboardHeader({
    super.key,
    required this.babyName,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFEC4899); // pink-500
    const pinkLight = Color(0xFFFCE7F3); // pink-100
    const textDark = Color(0xFF111827); // gray-900
    const textMuted = Color(0xFF6B7280); // gray-500

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Color(0x14000000),
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          // ✅ Smaller back icon (routes to /select-baby)
          IconButton(
            onPressed: () => context.go('/select-baby'),
            icon: const Icon(Icons.arrow_back_ios_new),
            color: textDark,
            iconSize: 18, // ✅ smaller
            splashRadius: 18,
            padding: EdgeInsets.zero, // ✅ less padding
            constraints: const BoxConstraints(
              minWidth: 34,
              minHeight: 34,
            ), // ✅ smaller tap area but still usable
            tooltip: 'Back',
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        babyName,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, color: pink, size: 14),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              subtitle,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ✅ Baby icon on the right (tap => /select-baby)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.go('/select-baby'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: pinkLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.child_friendly,
                          color: pink,
                          size: 30,
                        ),
                      ),
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF34D399),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
