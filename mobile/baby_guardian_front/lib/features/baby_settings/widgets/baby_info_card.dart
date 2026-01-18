import 'package:flutter/material.dart';
import 'package:baby_guardian_front/shared/widgets/app_card.dart';
import 'package:baby_guardian_front/shared/widgets/key_value_row.dart';

class BabyInfoCard extends StatelessWidget {
  final String age;
  final String dob;
  final String gender;

  const BabyInfoCard({
    super.key,
    required this.age,
    required this.dob,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Information',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          KeyValueRow(label: 'Age', value: age),
          const SizedBox(height: 12),
          KeyValueRow(label: 'Date of birth', value: dob),
          const SizedBox(height: 12),
          KeyValueRow(label: 'Gender', value: gender),
        ],
      ),
    );
  }
}
