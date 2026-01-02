import 'package:baby_guardian_front/shared/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ⬅️ go_router

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    // Splash un peu plus long (3 s), puis on laisse go_router décider.
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      // Variante A (recommandée) : route "pivot" '/'
      // => ta config go_router redirige vers /login ou /dashboard
      context.go('/');

      // Variante B : si tu préfères cibler directement une page :
      // context.go('/login');
      // ou si tu utilises des noms :
      // context.goNamed('login');
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double titleSize =
        (MediaQuery.of(context).size.width * 0.14).clamp(46.0, 68.0);

    return Container(
      decoration: const BoxDecoration(gradient: AppPalette.splashGradient),
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'Baby\nGuardian',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppPalette.onPrimary,
                  fontSize: titleSize,
                  height: 1.04,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
