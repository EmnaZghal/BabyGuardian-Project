// lib/features/home/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/dashboard_header.dart';
import '../widgets/section_header.dart';
import '../widgets/vital_card.dart';
import '../widgets/simple_info_card.dart';
import '../widgets/bar_sparkline.dart';
import '../widgets/device_status_card.dart';
import '../widgets/quick_action_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // Demo data
    final temps = <double>[36, 37, 36.8, 37.1, 37.2, 37.0, 37.2, 37.1, 37.2];
    final spo2 = <double>[97, 98, 98, 97, 98, 98, 99, 98, 98];
    final hr = <double>[120, 122, 125, 123, 124, 126, 124, 123, 124];

    return Scaffold(
      // ✅ No AppBar (top bar removed)
      body: SafeArea(
        bottom: false, // bottom handled by your ShellRoute + BottomNav
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEFF6FF), // blue-50
                Color(0xFFECFEFF), // cyan-50
                Color(0xFFF5F3FF), // purple-50
              ],
            ),
          ),
          child: Column(
            children: [
              // ✅ FIXED HEADER (does not scroll)
              DashboardHeader(babyName: "Emma", subtitle: "3 months and one"),

              // ✅ Scrollable content only
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        const SectionHeader(
                          title: "Vital signs",
                          trailingLive: true,
                        ),
                        const SizedBox(height: 10),

                        VitalCard(
                          title: "Body temperature",
                          valueText: "37.2",
                          unitBadge: "°C",
                          statusText: "Normal",
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                          ),
                          icon: Icons.thermostat,
                          sparkline: BarSparkline(
                            values: temps,
                            min: 35,
                            max: 38,
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFFEA580C), Color(0xFFFB923C)],
                            ),
                          ),
                          onTap: () =>
                              _showSnack(context, "Temperature details (demo)"),
                        ),
                        const SizedBox(height: 12),

                        VitalCard(
                          title: "Oxygen saturation",
                          valueText: "98",
                          unitBadge: "%",
                          statusText: "Optimal",
                          gradient: const LinearGradient(
                            colors: [Color(0xFF22D3EE), Color(0xFF0891B2)],
                          ),
                          icon: Icons.monitor_heart,
                          sparkline: BarSparkline(
                            values: spo2,
                            min: 90,
                            max: 100,
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFF0891B2), Color(0xFF22D3EE)],
                            ),
                          ),
                          onTap: () =>
                              _showSnack(context, "SpO2 details (demo)"),
                        ),
                        const SizedBox(height: 12),

                        VitalCard(
                          title: "Heart rate",
                          valueText: "124",
                          suffix: "bpm",
                          unitBadge: "+",
                          statusText: "Stable",
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF472B6), Color(0xFFDB2777)],
                          ),
                          icon: Icons.favorite,
                          animatePulseIcon: true,
                          sparkline: BarSparkline(
                            values: hr,
                            min: 110,
                            max: 140,
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xFFDB2777), Color(0xFFF472B6)],
                            ),
                          ),
                          onTap: () =>
                              _showSnack(context, "Heart rate details (demo)"),
                        ),
                        const SizedBox(height: 12),

                        SimpleInfoCard(
                          title: "Ambient humidity",
                          value: "56",
                          suffix: "%",
                          icon: Icons.water_drop,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                          ),
                          onTap: () =>
                              _showSnack(context, "Humidity details (demo)"),
                        ),

                        const SizedBox(height: 22),
                        const SectionHeader(title: "Wristband status"),
                        const SizedBox(height: 10),

                        DeviceStatusCard(
                          onTap: () =>
                              _showSnack(context, "Wristband details (demo)"),
                        ),

                        const SizedBox(height: 22),
                        const SectionHeader(title: "Quick access"),
                        const SizedBox(height: 10),

                        QuickActionButton(
                          title: "Health status",
                          subtitle: "Normal - All good",
                          icon: Icons.trending_up,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF0D9488)],
                          ),
                          onTap: () => context.go('/health-status'),

                        ),
                        const SizedBox(height: 12),

                        QuickActionButton(
                          title: "Predictions & Risks",
                          subtitle: "No risk detected",
                          icon: Icons.warning_amber_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          ),
                          onTap: () => context.go('/predictions'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
