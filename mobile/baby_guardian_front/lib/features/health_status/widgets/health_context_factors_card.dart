import 'package:flutter/material.dart';

class HealthContextFactorsCard extends StatelessWidget {
  final Map<String, String> items;
  final int monitoringDays;
  final int aiReliability;

  const HealthContextFactorsCard({
    super.key,
    required this.items,
    required this.monitoringDays,
    required this.aiReliability,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String dataQuality = items['Data quality'] ?? items['dataQuality'] ?? 'Excellent';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _kv('Data quality', dataQuality),
          const SizedBox(height: 12),
          _kv('Monitoring duration', '$monitoringDays days'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _kv('AI reliability', '$aiReliability%')),
              const SizedBox(width: 8),
              const Icon(Icons.info_outline, size: 16, color: Color(0xFF9CA3AF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          v,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
