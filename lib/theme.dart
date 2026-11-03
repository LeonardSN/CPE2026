import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF58CC02);
  static const greenDark = Color(0xFF46A302);
  static const red = Color(0xFFFF4B4B);
  static const redDark = Color(0xFFD33131);
  static const blue = Color(0xFF1CB0F6);
  static const orange = Color(0xFFFF9600);
  static const gold = Color(0xFFFFC800);
  static const grey = Color(0xFFE5E5E5);
  static const greyDark = Color(0xFFAFAFAF);
  static const text = Color(0xFF3C3C3C);
  static const lightGreen = Color(0xFFD7FFB8);
  static const lightRed = Color(0xFFFFDFE0);
}

/// Nom de l'app et de la mascotte : à changer ici si vous trouvez mieux.
class AppInfo {
  static const appName = 'Mathou';
  static const mascotEmoji = '🦊';
  static const mascotName = 'Mathou';
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
    scaffoldBackgroundColor: Colors.white,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.text,
    ),
  );
}
