import 'package:flutter/material.dart';
import 'vital_mini_card.dart';

class VitalsGrid extends StatelessWidget {
  const VitalsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: const [
        VitalMiniCard(
          icon: Icons.thermostat,
          iconBg: Color(0xFFFFEDD5), // orange-100
          iconColor: Color(0xFFF97316), // orange-500
          gradientColors: [Color(0xFFFFF7ED), Colors.white],
          value: '37.2°C',
          label: 'Temperature',
        ),
        VitalMiniCard(
          icon: Icons.monitor_heart,
          iconBg: Color(0xFFCFFAFE), // cyan-100
          iconColor: Color(0xFF06B6D4), // cyan-500
          gradientColors: [Color(0xFFECFEFF), Colors.white],
          value: '98%',
          label: 'SpO₂',
        ),
        VitalMiniCard(
          icon: Icons.favorite,
          iconBg: Color(0xFFFCE7F3), // pink-100
          iconColor: Color(0xFFEC4899), // pink-500
          gradientColors: [Color(0xFFFDF2F8), Colors.white],
          value: '124',
          label: 'bpm',
        ),
        VitalMiniCard(
          icon: Icons.water_drop,
          iconBg: Color(0xFFDBEAFE), // blue-100
          iconColor: Color(0xFF3B82F6), // blue-500
          gradientColors: [Color(0xFFEFF6FF), Colors.white],
          value: '56%',
          label: 'Humidity',
        ),
      ],
    );
  }
}
