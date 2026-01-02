import 'package:baby_guardian_front/shared/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:baby_guardian_front/app/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppPalette.oceanBlue),
        useMaterial3: true, // 💡 active Material 3 (pro et moderne)
      ),
      routerConfig: AppRouter.router, // ✅ correction ici
    );
  }
}
