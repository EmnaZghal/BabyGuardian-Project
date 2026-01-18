import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: gradient,
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
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 26),
          ],
        ),
      ),
    );
  }
}
