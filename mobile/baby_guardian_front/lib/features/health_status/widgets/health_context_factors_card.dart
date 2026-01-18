import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';
import 'package:baby_guardian_front/shared/widgets/key_value_row.dart';

class HealthContextFactorsCard extends StatelessWidget {
  final int monitoringDays;
  final int aiReliability;

  const HealthContextFactorsCard({
    super.key,
    required this.monitoringDays,
    required this.aiReliability,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const KeyValueRow(label: 'Data quality', value: 'Excellent'),
          const SizedBox(height: 12),
          KeyValueRow(label: 'Monitoring duration', value: '$monitoringDays days'),
          const SizedBox(height: 12),
          KeyValueRow(
            label: 'AI reliability',
            value: '$aiReliability%',
            trailing: const Icon(Icons.info_outline, size: 16, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}
