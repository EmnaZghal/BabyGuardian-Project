import 'package:flutter/material.dart';

class DeviceStatusCard extends StatelessWidget {
  final VoidCallback onTap;

  const DeviceStatusCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFFECFDF5), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.25)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              color: Color(0x14000000),
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF34D399), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 14,
                        color: Color(0x22059669),
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Icon(Icons.wifi, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Bracelet BR-001",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F9EF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "Connected",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Last measurement: 2 min ago",
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _MiniStatusBox(
                    icon: Icons.battery_full,
                    label: "Battery",
                    value: "87%",
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MiniStatusBox(
                    icon: Icons.wifi,
                    label: "Signal",
                    value: "Strong",
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _MiniStatusBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStatusBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.15)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x11000000),
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF059669)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF059669),
            ),
          )
        ],
      ),
    );
  }
}
