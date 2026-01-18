import 'package:flutter/material.dart';

enum AlertsFilter { all, health, device, unread }

class AlertsFilterBar extends StatelessWidget {
  final AlertsFilter value;
  final ValueChanged<AlertsFilter> onChanged;

  const AlertsFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          _chip(
            label: 'All',
            selected: value == AlertsFilter.all,
            onTap: () => onChanged(AlertsFilter.all),
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Health',
            selected: value == AlertsFilter.health,
            onTap: () => onChanged(AlertsFilter.health),
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Device',
            selected: value == AlertsFilter.device,
            onTap: () => onChanged(AlertsFilter.device),
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Unread',
            selected: value == AlertsFilter.unread,
            onTap: () => onChanged(AlertsFilter.unread),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    blurRadius: 12,
                    color: Color(0x22000000),
                    offset: Offset(0, 6),
                  )
                ]
              : const [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
