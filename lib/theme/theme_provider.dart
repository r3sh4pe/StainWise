import 'package:flutter/material.dart';

import 'theme_constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeVariant _currentVariant = ThemeVariant.macchiato;
  bool _isDark = true;

  ThemeVariant get currentVariant => _currentVariant;

  bool get isDark => _isDark;

  void setThemeVariant(ThemeVariant variant) {
    _currentVariant = variant;
    _isDark = variant != ThemeVariant.latte;
    notifyListeners();
  }

  ThemeData getTheme() {
    final palette = _getPalette();

    return ThemeData(
      useMaterial3: true,
      brightness: _isDark ? Brightness.dark : Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        primary: palette.blue,
        onPrimary: palette.base,
        secondary: palette.mauve,
        onSecondary: palette.base,
        error: palette.red,
        onError: palette.base,
        surface: palette.base,
        onSurface: palette.text,
        // Using surface and onSurface instead of deprecated background/onBackground
        surfaceTint: palette.surface0,
        inverseSurface: palette.crust,
        onInverseSurface: palette.text,
        surfaceContainerHighest: palette.surface1,
        onSurfaceVariant: palette.text,
      ),

      // Scaffold background color
      scaffoldBackgroundColor: palette.base,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: palette.mantle,
        foregroundColor: palette.text,
        elevation: 0,
      ),

      // Card theme
      cardTheme: CardTheme(
        color: palette.surface0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.blue, width: 2),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.blue,
        foregroundColor: palette.base,
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.blue,
          foregroundColor: palette.base,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.blue;
          }
          return palette.overlay0;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.blue.withValues(
                alpha: 128); // Using withValues instead of withOpacity
          }
          return palette.surface2;
        }),
      ),
    );
  }

  CatppuccinPalette _getPalette() {
    switch (_currentVariant) {
      case ThemeVariant.latte:
        return CatppuccinColors.lattePalette;
      case ThemeVariant.frappe:
        return CatppuccinColors.frappePalette;
      case ThemeVariant.macchiato:
        return CatppuccinColors.macchiatoPalette;
      case ThemeVariant.mocha:
        return CatppuccinColors.mochaPalette;
    }
  }
}
