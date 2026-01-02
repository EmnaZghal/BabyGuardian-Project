import 'package:go_router/go_router.dart';
import 'package:baby_guardian_front/features/auth/views/login_page.dart';
import 'package:baby_guardian_front/features/auth/views/sign_up_page.dart';
import 'package:baby_guardian_front/features/home/home_page.dart';

class AppRouter {
  // simulateur d’authentification (plus tard tu utiliseras un vrai service)
  static bool isLoggedIn = false;

  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],

    // Redirection automatique (par ex. si pas loggé → forcer login)
    redirect: (context, state) {
      final loggingIn = state.fullPath == '/login' || state.fullPath == '/signup';

      if (!isLoggedIn && !loggingIn) {
        return '/login';
      }
      if (isLoggedIn && loggingIn) {
        return '/home';
      }
      return null; // pas de redirection
    },
  );
}
