import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Dark palette ───
class AppColors {
  static const Color background = Color(0xFF131313);
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainerLowest = Color(0xFF0e0e0e);
  static const Color surfaceContainerLow = Color(0xFF1c1b1b);
  static const Color surfaceContainer = Color(0xFF20201f);
  static const Color surfaceContainerHigh = Color(0xFF2a2a2a);
  static const Color surfaceContainerHighest = Color(0xFF353535);
  static const Color surfaceBright = Color(0xFF393939);
  static const Color onSurface = Color(0xFFe5e2e1);
  static const Color onSurfaceVariant = Color(0xFFddc0ba);
  static const Color primary = Color(0xFFffb4a5);
  static const Color primaryContainer = Color(0xFFe2725b);
  static const Color onPrimary = Color(0xFF611205);
  static const Color onPrimaryContainer = Color(0xFF5a0d02);
  static const Color secondary = Color(0xFFe4c09a);
  static const Color secondaryContainer = Color(0xFF5b4225);
  static const Color tertiary = Color(0xFFddc0b9);
  static const Color error = Color(0xFFffb4ab);
  static const Color errorContainer = Color(0xFF93000a);
  static const Color outline = Color(0xFFa48b86);
  static const Color outlineVariant = Color(0xFF56423e);
  static const Color inversePrimary = Color(0xFF9f402d);
  static const Color inverseSurface = Color(0xFFe5e2e1);
  static const Color onBackground = Color(0xFFe5e2e1);
}

// ─── Light palette ───
class AppColorsLight {
  static const Color background = Color(0xFFFFFBFF);
  static const Color surface = Color(0xFFFFFBFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F2F1);
  static const Color surfaceContainer = Color(0xFFF1ECEB);
  static const Color surfaceContainerHigh = Color(0xFFEBE6E5);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color surfaceBright = Color(0xFFFFFBFF);
  static const Color onSurface = Color(0xFF201A19);
  static const Color onSurfaceVariant = Color(0xFF56423E);
  static const Color primary = Color(0xFF9F402D);
  static const Color primaryContainer = Color(0xFFFFDAD3);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF3E0400);
  static const Color secondary = Color(0xFF77574B);
  static const Color secondaryContainer = Color(0xFFFFDAD0);
  static const Color tertiary = Color(0xFF6E5D57);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color outline = Color(0xFF8A736E);
  static const Color outlineVariant = Color(0xFFD8C2BC);
  static const Color inversePrimary = Color(0xFFFFB4A5);
  static const Color inverseSurface = Color(0xFF362F2E);
  static const Color onBackground = Color(0xFF201A19);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 40;
  static const double marginMobile = 16;
  static const double gutter = 24;
}

class AppTheme {
  // ─── DARK ───
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        onPrimary: AppColors.onPrimary,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.tertiary,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inversePrimary: AppColors.inversePrimary,
        inverseSurface: AppColors.inverseSurface,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        surfaceBright: AppColors.surfaceBright,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.montserratTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 40, height: 48 / 40, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          headlineLarge: TextStyle(fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          headlineMedium: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          bodyLarge: TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w400, color: AppColors.onSurface),
          bodyMedium: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400, color: AppColors.onSurface),
          labelLarge: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          labelSmall: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceContainer,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error),
          borderRadius: BorderRadius.circular(12),
        ),
        hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
    );
  }

  // ─── LIGHT ───
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        surface: AppColorsLight.surface,
        onSurface: AppColorsLight.onSurface,
        onSurfaceVariant: AppColorsLight.onSurfaceVariant,
        primary: AppColorsLight.primary,
        primaryContainer: AppColorsLight.primaryContainer,
        onPrimary: AppColorsLight.onPrimary,
        onPrimaryContainer: AppColorsLight.onPrimaryContainer,
        secondary: AppColorsLight.secondary,
        secondaryContainer: AppColorsLight.secondaryContainer,
        tertiary: AppColorsLight.tertiary,
        error: AppColorsLight.error,
        errorContainer: AppColorsLight.errorContainer,
        outline: AppColorsLight.outline,
        outlineVariant: AppColorsLight.outlineVariant,
        inversePrimary: AppColorsLight.inversePrimary,
        inverseSurface: AppColorsLight.inverseSurface,
        surfaceContainerLowest: AppColorsLight.surfaceContainerLowest,
        surfaceContainerLow: AppColorsLight.surfaceContainerLow,
        surfaceContainer: AppColorsLight.surfaceContainer,
        surfaceContainerHigh: AppColorsLight.surfaceContainerHigh,
        surfaceContainerHighest: AppColorsLight.surfaceContainerHighest,
        surfaceBright: AppColorsLight.surfaceBright,
      ),
      scaffoldBackgroundColor: AppColorsLight.background,
      textTheme: GoogleFonts.montserratTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 40, height: 48 / 40, fontWeight: FontWeight.w700, color: AppColorsLight.onSurface),
          headlineLarge: TextStyle(fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w600, color: AppColorsLight.onSurface),
          headlineMedium: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, color: AppColorsLight.onSurface),
          bodyLarge: TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w400, color: AppColorsLight.onSurface),
          bodyMedium: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400, color: AppColorsLight.onSurface),
          labelLarge: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: AppColorsLight.onSurface),
          labelSmall: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: AppColorsLight.onSurface),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorsLight.surfaceContainer,
        foregroundColor: AppColorsLight.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsLight.surfaceContainer,
        selectedItemColor: AppColorsLight.primary,
        unselectedItemColor: AppColorsLight.onSurfaceVariant,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColorsLight.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColorsLight.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColorsLight.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColorsLight.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColorsLight.error),
          borderRadius: BorderRadius.circular(12),
        ),
        hintStyle: const TextStyle(color: AppColorsLight.onSurfaceVariant),
        labelStyle: const TextStyle(color: AppColorsLight.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsLight.primary,
          foregroundColor: AppColorsLight.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── ThemeProvider ───
class ThemeProvider with ChangeNotifier {
  static const _key = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> toggleTheme() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, isDark ? 'dark' : 'light');
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }
}
