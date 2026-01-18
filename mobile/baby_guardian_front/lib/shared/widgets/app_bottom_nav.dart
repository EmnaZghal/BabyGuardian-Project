import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,

      selectedItemColor: const Color(0xFFEC4899), // pink
      unselectedItemColor: const Color(0xFF9CA3AF),

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.child_friendly_outlined),
          activeIcon: Icon(Icons.child_friendly),
          label: 'Baby',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy_outlined),
          activeIcon: Icon(Icons.smart_toy),
          label: 'Assistant',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
