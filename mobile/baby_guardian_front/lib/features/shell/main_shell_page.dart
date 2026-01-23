import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_guardian_front/shared/widgets/app_bottom_nav.dart';

class MainShellPage extends StatelessWidget {
  final Widget child;

  const MainShellPage({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/alerts')) return 1;
    if (location.startsWith('/baby-settings')) return 2; // ✅ Baby au milieu
    if (location.startsWith('/assistant')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0; // /home
  }

  String _indexToLocation(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/alerts';
      case 2:
        return '/baby-settings'; // ✅ page Baby
      case 3:
        return '/assistant';
      case 4:
        return '/settings';
      default:
        return '/home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (i) {
          final target = _indexToLocation(i);
          if (target != location) context.go(target);
        },
      ),
    );
  }
}
