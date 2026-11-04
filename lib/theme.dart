import 'package:flutter/material.dart';

// =====================================================================
//  IDENTITÉ VISUELLE MATHOU
//  Palette : orange #FF8C38 · bleu foncé #16355F · noir #232323 · blanc
//  Polices : Nunito (titres, boutons) · Quicksand (textes, explications)
//  Le thème change selon le cycle d'études, en clair ou en sombre.
// =====================================================================

class Brand {
  static const orange = Color(0xFFFF8C38);
  static const orangeDark = Color(0xFFE0701E);
  static const navy = Color(0xFF16355F);
  static const navyDark = Color(0xFF0E2443);
  static const blue = Color(0xFF2A5C96);
  static const ink = Color(0xFF232323);
  static const white = Color(0xFFFFFFFF);
  static const cream = Color(0xFFFFF7EF);
}

/// Couleurs « de sens » : vert = juste, rouge = faux, etc.
/// Elles restent les mêmes dans tous les thèmes.
class AppColors {
  static const green = Color(0xFF58CC02);
  static const greenDark = Color(0xFF46A302);
  static const red = Color(0xFFFF4B4B);
  static const redDark = Color(0xFFD33131);
  static const blue = Brand.blue;
  static const orange = Brand.orange;
  static const gold = Color(0xFFFFC23D);
  static const grey = Color(0xFFE3E3E3);
  static const greyDark = Color(0xFF9A9A9A);
  static const text = Brand.ink;
  static const lightGreen = Color(0xFFD7FFB8);
  static const lightRed = Color(0xFFFFDFE0);
}

/// Nom de l'app et de la mascotte.
class AppInfo {
  static const appName = 'Mathou';
  static const mascotEmoji = '🐱';
  static const mascotName = 'Mathou';
  static const mascotImage = 'assets/images/mathou.png';
}

/// Palette d'un cycle : couleur principale, secondaire et fond.
class CyclePalette {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;

  /// Version mode sombre.
  final Color darkPrimary;
  final Color darkBackground;
  final Color darkSurface;

  const CyclePalette({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.darkPrimary,
    this.darkBackground = Brand.ink,
    this.darkSurface = const Color(0xFF2E2E2E),
  });

  /// Une palette par cycle : de plus en plus sobre en grandissant.
  static const byCycle = {
    // Maternelle : orange et jaune chaleureux, très joyeux
    'cycle1': CyclePalette(
      primary: Brand.orange,
      secondary: Color(0xFFFFC23D),
      background: Color(0xFFFFF6E6),
      surface: Brand.white,
      darkPrimary: Color(0xFFFFA45C),
      darkBackground: Color(0xFF2A2118),
      darkSurface: Color(0xFF3A2E22),
    ),
    // CP-CE2 : la palette de base Mathou (orange + bleu foncé)
    'cycle2': CyclePalette(
      primary: Brand.orange,
      secondary: Brand.navy,
      background: Brand.white,
      surface: Brand.white,
      darkPrimary: Brand.orange,
    ),
    // CM1-6e : le bleu prend le dessus, l'orange reste l'accent
    'cycle3': CyclePalette(
      primary: Brand.blue,
      secondary: Brand.orange,
      background: Color(0xFFF3F7FC),
      surface: Brand.white,
      darkPrimary: Color(0xFF6FA3E0),
      darkBackground: Color(0xFF151C26),
      darkSurface: Color(0xFF1F2835),
    ),
    // 5e-3e : bleu foncé, plus sérieux
    'cycle4': CyclePalette(
      primary: Brand.navy,
      secondary: Brand.orange,
      background: Color(0xFFF1F3F7),
      surface: Brand.white,
      darkPrimary: Color(0xFF8FB4E8),
      darkBackground: Color(0xFF0F1826),
      darkSurface: Color(0xFF1A2537),
    ),
    // Lycée : sobre, noir et orange
    'lycee': CyclePalette(
      primary: Brand.ink,
      secondary: Brand.orange,
      background: Color(0xFFF5F5F5),
      surface: Brand.white,
      darkPrimary: Brand.orange,
      darkBackground: Color(0xFF161616),
      darkSurface: Color(0xFF242424),
    ),
  };

  static CyclePalette of(String schoolId) => byCycle[schoolId] ?? byCycle['cycle2']!;
}

/// Couleur un peu plus foncée (pour le rebord des boutons « 3D »).
Color darker(Color c, [double amount = 0.12]) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

/// Texte lisible (blanc ou noir) sur une couleur de fond.
Color onColor(Color c) => c.computeLuminance() > 0.55 ? Brand.ink : Brand.white;

ThemeData buildTheme(String schoolId, Brightness brightness) {
  final p = CyclePalette.of(schoolId);
  final dark = brightness == Brightness.dark;
  final primary = dark ? p.darkPrimary : p.primary;
  final bg = dark ? p.darkBackground : p.background;
  final surface = dark ? p.darkSurface : p.surface;
  final text = dark ? const Color(0xFFF2F2F2) : Brand.ink;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: onColor(primary),
    secondary: p.secondary,
    onSecondary: onColor(p.secondary),
    error: AppColors.red,
    onError: Brand.white,
    surface: surface,
    onSurface: text,
    surfaceContainerHighest: dark ? const Color(0xFF3A3A3A) : const Color(0xFFF2F2F2),
    outline: dark ? const Color(0xFF555555) : AppColors.grey,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: bg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: text,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w800,
        fontSize: 20,
        color: text,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: primary.withValues(alpha: 0.18),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: text),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: surface),
    dividerColor: scheme.outline,
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

/// Styles de texte pratiques.
class AppText {
  /// Paragraphe (explications, descriptions) en Quicksand.
  static const body = TextStyle(fontFamily: 'Quicksand', fontWeight: FontWeight.w600, height: 1.4);
}

/// Petits raccourcis pour accéder au thème.
extension ThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Couleur d'une carte (blanc en clair, gris foncé en sombre).
  Color get card => Theme.of(this).colorScheme.surface;

  /// Texte secondaire.
  Color get muted => isDark ? const Color(0xFFB0B0B0) : AppColors.greyDark;
}
