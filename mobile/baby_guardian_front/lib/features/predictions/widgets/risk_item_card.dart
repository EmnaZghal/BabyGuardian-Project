import 'package:flutter/material.dart';
import '../models/risk_item.dart';

class RiskItemCard extends StatelessWidget {
  final RiskItem item;
  const RiskItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = item.score <= 1.0 ? item.score * 100 : item.score;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.tertiary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  if (item.details != null && item.details!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(item.details!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('${pct.toStringAsFixed(1)}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
