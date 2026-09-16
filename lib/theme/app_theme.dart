import 'package:flutter/material.dart';

/// Central place for FocusFlow's visual identity and design tokens.
///
/// FocusFlow uses a light, Material 3 theme built from a deep indigo / purple
/// seed color. Screens and widgets should reference the semantic roles from
/// [ColorScheme] and the tokens below instead of scattering hardcoded values.
class FocusFlowTheme {
  // Private constructor marks this as a static utility class.
  const FocusFlowTheme._();

  /// Deep indigo / purple seed used to derive the full Material 3 color scheme.
  static const Color seedColor = Colors.deepPurple;

  // ---------------------------------------------------------------------------
  // Spacing scale (4 pt grid, comfortable for a productivity app)
  // ---------------------------------------------------------------------------

  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;

  /// Standard horizontal + vertical inset for scrollable screen content.
  static const EdgeInsets screenInset = EdgeInsets.fromLTRB(20, 22, 20, 26);

  /// Standard inner padding for cards.
  static const EdgeInsets cardPadding = EdgeInsets.all(20);

  // ---------------------------------------------------------------------------
  // Corner radius scale — keeps cards, chips and buttons visually consistent.
  // ---------------------------------------------------------------------------

  /// Small radii for chips, checkmarks and compact surfaces.
  static const Radius radiusS = Radius.circular(12);

  /// Standard card radius.
  static const Radius radiusM = Radius.circular(18);

  /// Prominent cards (highlight cards, profile).
  static const Radius radiusL = Radius.circular(24);

  /// Hero surfaces (large focus card).
  static const Radius radiusXL = Radius.circular(28);

  // ---------------------------------------------------------------------------
  // Color surfaces
  // ---------------------------------------------------------------------------

  /// Soft off-white with a whisper of lavender, used as the light app canvas.
  static final Color lightScaffold = const Color(0xFFF8F7FB);

  /// Deep, calm indigo-black used as the dark app canvas.
  static final Color darkScaffold = const Color(0xFF14131A);

  // ---------------------------------------------------------------------------
  // Typography
  // ---------------------------------------------------------------------------

  /// A coherent type scale for the app's clear typography hierarchy.
  ///
  /// Screens reference these styles via `Theme.of(context).textTheme` so the
  /// whole app can be retyped from this single place.
  static TextTheme textTheme() {
    return TextTheme(
      displayLarge: const TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
      displayMedium: const TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: const TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }

  // ---------------------------------------------------------------------------
  // Theme builders
  // ---------------------------------------------------------------------------

  /// Builds the polished light theme used by the app.
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      scaffoldBackgroundColor: lightScaffold,
      textTheme: textTheme(),
    );
  }

  /// A sensible dark theme foundation, ready to enable in a future release.
  ///
  /// It is wired into [MaterialApp.darkTheme] so toggling to a dark experience
  /// later only requires flipping the theme mode.
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkScaffold,
      textTheme: textTheme(),
    );
  }
}
