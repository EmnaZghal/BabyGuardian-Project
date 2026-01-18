import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/alert_item.dart';
import '../widgets/alerts_filter_bar.dart';
import '../widgets/alert_tile.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  AlertsFilter filter = AlertsFilter.all;

  // Demo data (static UI)
  final List<AlertItem> alerts = const [
    AlertItem(
      id: 1,
      type: AlertType.health,
      severity: AlertSeverity.medium,
      title: 'High temperature',
      message: 'Temperature at 38.1°C',
      timeLabel: '10:14',
      icon: Icons.thermostat,
      iconBg: Color(0xFFFFEDD5),   // orange-100
      iconColor: Color(0xFFF97316),// orange-500
      read: false,
    ),
    AlertItem(
      id: 2,
      type: AlertType.device,
      severity: AlertSeverity.low,
      title: 'Low battery',
      message: 'Battery level at 15%',
      timeLabel: '09:32',
      icon: Icons.battery_alert_outlined,
      iconBg: Color(0xFFFEF9C3),   // yellow-100
      iconColor: Color(0xFFEAB308),// yellow-500
      read: false,
    ),
    AlertItem(
      id: 3,
      type: AlertType.health,
      severity: AlertSeverity.low,
      title: 'Slightly low SpO₂',
      message: 'SpO₂ at 95% for 2 min',
      timeLabel: '08:45',
      icon: Icons.monitor_heart_outlined,
      iconBg: Color(0xFFCFFAFE),   // cyan-100
      iconColor: Color(0xFF06B6D4),// cyan-500
      read: true,
    ),
    AlertItem(
      id: 4,
      type: AlertType.device,
      severity: AlertSeverity.medium,
      title: 'Connection lost',
      message: 'Wristband disconnected for 5 min',
      timeLabel: 'Yesterday',
      icon: Icons.wifi_off,
      iconBg: Color(0xFFDBEAFE),   // blue-100
      iconColor: Color(0xFF3B82F6),// blue-500
      read: true,
    ),
  ];

  List<AlertItem> get filtered {
    switch (filter) {
      case AlertsFilter.all:
        return alerts;
      case AlertsFilter.health:
        return alerts.where((a) => a.type == AlertType.health).toList();
      case AlertsFilter.device:
        return alerts.where((a) => a.type == AlertType.device).toList();
      case AlertsFilter.unread:
        return alerts.where((a) => !a.read).toList();
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = filtered;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x14000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Alerts',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _toast('Notifications (UI only)'),
            icon: const Icon(Icons.notifications_outlined),
            color: const Color(0xFF3B82F6),
          ),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filters
              AlertsFilterBar(
                value: filter,
                onChanged: (v) => setState(() => filter = v),
              ),
              const SizedBox(height: 14),

              // List / Empty state
              if (list.isEmpty)
                Column(
                  children: const [
                    SizedBox(height: 40),
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xFFDCFCE7),
                      child: Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 34),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Everything looks fine for now!',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    for (final a in list) ...[
                      AlertTile(
                        alert: a,
                        onTap: () => _toast('Open alert details (UI only)'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
