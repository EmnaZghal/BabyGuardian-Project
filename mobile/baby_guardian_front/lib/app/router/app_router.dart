import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baby_guardian_front/features/auth/views/login_page.dart';
import 'package:baby_guardian_front/features/auth/views/sign_up_page.dart';
import 'package:baby_guardian_front/features/babies_page_selection/views/baby_select_page.dart';
import 'package:baby_guardian_front/features/babies_page_selection/views/baby_create_page.dart';
import 'package:baby_guardian_front/features/babies_page_selection/views/add_baby_form.dart';

import 'package:baby_guardian_front/features/shell/main_shell_page.dart';
import 'package:baby_guardian_front/features/home/views/home_page.dart';
import 'package:baby_guardian_front/features/baby_settings/views/baby_settings.dart';
import 'package:baby_guardian_front/features/alerts/views/alerts_page.dart';
import 'package:baby_guardian_front/features/assistant/views/assistant_page.dart';
import 'package:baby_guardian_front/features/settings/views/settings_page.dart';
import 'package:baby_guardian_front/features/health_status/views/health_status_page.dart';
import 'package:baby_guardian_front/features/predictions/views/predictions_page.dart';

class AppRouter {
  static bool isLoggedIn = false;

  static final _rootKey = GlobalKey<NavigatorState>();
  static final _shellKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SignUpPage(),
      ),

      GoRoute(
        path: '/add-baby',
        builder: (context, state) => const AddBabyFormPage(),
      ),
      GoRoute(
        path: '/select-baby',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const BabySelectPage(),
      ),
      GoRoute(
        path: '/health-status',
        builder: (context, state) => const HealthStatusPage(),
      ),
      GoRoute(
        path: '/predictions',
        builder: (context, state) => const PredictionsPage(),
      ),
      GoRoute(
        path: '/baby-create',
        builder: (context, state) => const BabyCreatePage(),
      ),

      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(
            path: '/home',
            parentNavigatorKey: _shellKey,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/baby-settings',
            parentNavigatorKey: _shellKey,
            builder: (context, state) => const BabySettings(),
          ),
          GoRoute(
            path: '/alerts',
            parentNavigatorKey: _shellKey,
            builder: (context, state) => const AlertsPage(),
          ),
          GoRoute(
            path: '/assistant',
            parentNavigatorKey: _shellKey,
            builder: (context, state) => const AssistantPage(),
          ),
          GoRoute(
            path: '/settings',
            parentNavigatorKey: _shellKey,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthPage = path == '/login' || path == '/signup';

      if (!isLoggedIn && !isAuthPage) return '/login';
      if (isLoggedIn && isAuthPage) return '/select-baby';

      return null;
    },
  );
}
