import 'package:flutter/material.dart';

import 'package:baby_guardian_front/shared/widgets/section_title.dart';

import '../widgets/settings_group.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_switch_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool healthAlerts = true;
  bool deviceAlerts = true;
  bool nightMode = false;

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x14000000),

        // ✅ removed back icon
        automaticallyImplyLeading: false,

        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== Account =====
              const SectionTitle('Account'),
              const SizedBox(height: 10),
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.person_outline,
                    iconBg: const Color(0xFFDBEAFE), // blue-100
                    iconColor: const Color(0xFF3B82F6), // blue-500
                    title: 'Parent profile',
                    subtitle: 'parent@example.com',
                    onTap: () => _toast('Parent profile (UI only)'),
                  ),
                  SettingsTile(
                    icon: Icons.shield_outlined,
                    iconBg: const Color(0xFFEDE9FE), // purple-100
                    iconColor: const Color(0xFF8B5CF6), // purple-500
                    title: 'Security & privacy',
                    subtitle: 'Manage your data',
                    onTap: () => _toast('Security & privacy (UI only)'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ===== Notifications =====
              const SectionTitle('Notifications'),
              const SizedBox(height: 10),
              SettingsGroup(
                children: [
                  SettingsSwitchTile(
                    icon: Icons.notifications_none,
                    iconBg: const Color(0xFFFFEDD5), // orange-100
                    iconColor: const Color(0xFFF97316), // orange-500
                    title: 'Health alerts',
                    subtitle: 'Temperature, SpO₂, HR',
                    value: healthAlerts,
                    onChanged: (v) => setState(() => healthAlerts = v),
                  ),
                  SettingsSwitchTile(
                    icon: Icons.smartphone_outlined,
                    iconBg: const Color(0xFFDBEAFE), // blue-100
                    iconColor: const Color(0xFF3B82F6), // blue-500
                    title: 'Device alerts',
                    subtitle: 'Battery, connection',
                    value: deviceAlerts,
                    onChanged: (v) => setState(() => deviceAlerts = v),
                  ),
                  SettingsSwitchTile(
                    icon: Icons.nightlight_round,
                    iconBg: const Color(0xFFE0E7FF), // indigo-100
                    iconColor: const Color(0xFF6366F1), // indigo-500
                    title: 'Night mode',
                    subtitle: 'Silence 10pm - 7am',
                    value: nightMode,
                    onChanged: (v) => setState(() => nightMode = v),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ===== Wristband =====
              const SectionTitle('Wristband'),
              const SizedBox(height: 10),
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.phone_android,
                    iconBg: const Color(0xFFCFFAFE), // cyan-100
                    iconColor: const Color(0xFF06B6D4), // cyan-500
                    title: 'Manage wristbands',
                    subtitle: '1 wristband connected',
                    onTap: () => _toast('Manage wristbands (UI only)'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ===== Help & support =====
              const SectionTitle('Help & support'),
              const SizedBox(height: 10),
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.chat_bubble_outline,
                    iconBg: const Color(0xFFDCFCE7), // green-100
                    iconColor: const Color(0xFF22C55E), // green-500
                    title: 'User guide',
                    subtitle: 'FAQ & tutorials',
                    onTap: () => _toast('User guide (UI only)'),
                  ),
                  SettingsTile(
                    icon: Icons.info_outline,
                    iconBg: const Color(0xFFFEF9C3), // yellow-100
                    iconColor: const Color(0xFFD97706), // amber-600
                    title: 'About',
                    subtitle: 'Version 1.0.0',
                    onTap: () => _toast('About (UI only)'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ===== Logout =====
              InkWell(
                onTap: () => _toast('Sign out (UI only)'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2), // red-50
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFECACA)), // red-200
                  ),
                  child: const Center(
                    child: Text(
                      'Sign out',
                      style: TextStyle(
                        color: Color(0xFFDC2626), // red-600
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
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
