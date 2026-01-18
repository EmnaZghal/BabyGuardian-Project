import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baby_guardian_front/shared/widgets/section_title.dart';

import '../widgets/baby_profile_header.dart';
import '../widgets/baby_info_card.dart';
import '../widgets/vitals_grid.dart';
import '../widgets/wristband_card.dart';
import '../widgets/baseline_card.dart';

class BabySettings extends StatelessWidget {
  const BabySettings({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Static demo data (UI only)
    const babyName = 'Emma';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x14000000),
        automaticallyImplyLeading: false,
        title: const Text(
          'Emma profile',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _toast(context, 'Edit (UI only)'),
            icon: const Icon(Icons.edit_outlined),
            color: const Color(0xFF3B82F6),
            tooltip: 'Edit',
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFF6FF), // blue-50
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header (avatar + name + status)
              BabyProfileHeader(name: babyName),
              const SizedBox(height: 18),

              // Information card
              const BabyInfoCard(
                age: '3 months and 1 week',
                dob: 'October 1, 2025',
                gender: 'Female',
              ),
              const SizedBox(height: 18),

              // Current vitals
              const SectionTitle('Current vitals'),
              const SizedBox(height: 10),
              const VitalsGrid(),
              const SizedBox(height: 18),

              // Wristband
              const SectionTitle('Linked wristband'),
              const SizedBox(height: 10),
              const WristbandCard(),
              const SizedBox(height: 18),

              // Baseline
              const SectionTitle('Baseline & Calibration'),
              const SizedBox(height: 10),
              const BaselineCard(),
            ],
          ),
        ),
      ),
    );
  }
}
