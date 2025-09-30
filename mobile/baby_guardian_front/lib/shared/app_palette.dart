import 'package:flutter/material.dart';

/// Palette centrale (une seule source de vérité)
abstract final class AppPalette {
  // Couleurs du branding BabyGuardian (écran splash)
  static const Color turquoise  = Color(0xFF7EC6C6);
  static const Color oceanBlue  = Color(0xFF5C90C1);

  // Couleurs utilitaires
  static const Color onPrimary  = Colors.white;
  static const Color bg         = Colors.white;

  // Dégradés
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [turquoise, oceanBlue],
  );
}
