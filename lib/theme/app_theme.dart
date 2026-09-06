import 'package:flutter/material.dart';

/// Central place for FocusFlow's visual theming.
///
/// FocusFlow uses a light, Material 3 theme built from a deep indigo / purple
/// seed color. Keep app-specific styling in this file so screens and widgets
/// reference semantic roles (colors from [ColorScheme]) rather than scattered
/// hardcoded values.
class FocusFlowTheme {
  // Private constructor marks this as a static utility class.
  const FocusFlowTheme._();

  /// Deep indigo / purple seed used to derive the full Material 3 color scheme.
  static const Color seedColor = Colors.deepPurple;

  /// The light theme used across the app.
  ///
  /// Components resolve their colors from this [ThemeData] via the ambient
  /// [Theme] when they are built, so swapping the seed or brightness here
  /// restyles the whole app.
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
    );
  }
}