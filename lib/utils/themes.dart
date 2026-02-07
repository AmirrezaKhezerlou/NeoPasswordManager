// app_themes.dart
import 'package:flutter/material.dart';
import 'package:password_manager/utils/consts.dart';

class AppThemes {
  static final Color _scaffoldLight = const Color(0xFFF2F2F7);
  static final Color _scaffoldDark = const Color(0xFF000000);
  static final Color _cardDark = const Color(0xFF1C1C1E);
  static final Color _primaryLight = const Color(0xFF007AFF);
  static final Color _primaryDark = const Color(0xFF0A84FF);
  static final Color _secondaryLight = const Color(0xFF1C1C1E);
  static final Color _secondaryDark = const Color(0xFFE5E5EA);
  static final Color _surfaceLight = const Color(0xFFFFFFFF);
  static final Color _surfaceDark = const Color(0xFF1C1C1E);
  static final Color _onSurfaceLight = const Color(0xFF1C1C1E);
  static final Color _onSurfaceDark = const Color(0xFFE5E5EA);
  static final Color _errorLight = const Color(0xFFFF3B30);
  static final Color _errorDark = const Color(0xFFFF453A);
  static final Color _backgroundLight = const Color(0xFFF2F2F7);
  static final Color _backgroundDark = const Color(0xFF000000);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: _primaryLight,
    scaffoldBackgroundColor: _scaffoldLight,
    cardColor: _surfaceLight,
    appBarTheme: AppBarTheme(
      backgroundColor: _scaffoldLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _onSurfaceLight,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryLight,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _errorLight,
        side: BorderSide(color: _errorLight, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _secondaryLight.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _secondaryLight.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryLight, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(
        fontSize: 16,
        color: _secondaryLight,
      ),
      hintStyle: TextStyle(
        fontSize: 16,
        color: _secondaryLight.withOpacity(0.5),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: _onSurfaceLight,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _onSurfaceLight,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: _onSurfaceLight,
      ),
      headlineMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _onSurfaceLight,
      ),
      headlineSmall:  TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _onSurfaceLight,
      ),
      titleLarge:  TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _onSurfaceLight,
      ),
      titleMedium:  TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _onSurfaceLight,
      ),
      titleSmall:  TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _onSurfaceLight,
      ),
      bodyLarge:  TextStyle(
        fontSize: 17,
        color: _secondaryLight,
      ),
      bodyMedium:  TextStyle(
        fontSize: 15,
        color: _secondaryLight,
      ),
      bodySmall:  TextStyle(
        fontSize: 13,
        color: _secondaryLight,
      ),
      labelLarge:  TextStyle(
        fontSize: 17,
        color: _onSurfaceLight,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: _primaryLight,
      secondary: _secondaryLight,
      surface: _surfaceLight,
      background: _backgroundLight,
      error: _errorLight,
      onPrimary: Colors.white,
      onSecondary: _onSurfaceLight,
      onSurface: _onSurfaceLight,
      onBackground: _onSurfaceLight,
      onError: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    primaryColor: _primaryDark,
    scaffoldBackgroundColor: _scaffoldDark,
    cardColor: _surfaceDark,
    appBarTheme:  AppBarTheme(
      backgroundColor: _scaffoldDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _onSurfaceDark,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    ),
    dialogTheme:  DialogThemeData(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryDark,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _errorDark,
        side: BorderSide(color: _errorDark, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _secondaryDark.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _secondaryDark.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryDark, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle:  TextStyle(
        fontSize: 16,
        color: _secondaryDark,
      ),
      hintStyle: TextStyle(
        fontSize: 16,
        color: _secondaryDark.withOpacity(0.5),
      ),
    ),
    textTheme:  TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: _onSurfaceDark,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _onSurfaceDark,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: _onSurfaceDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _onSurfaceDark,
      ),
      headlineSmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _onSurfaceDark,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _onSurfaceDark,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _onSurfaceDark,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _onSurfaceDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        color: _secondaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: _secondaryDark,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        color: _secondaryDark,
      ),
      labelLarge: TextStyle(
        fontSize: 17,
        color: _onSurfaceDark,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: _primaryDark,
      secondary: _secondaryDark,
      surface: _surfaceDark,
      background: _backgroundDark,
      error: _errorDark,
      onPrimary: Colors.white,
      onSecondary: _onSurfaceDark,
      onSurface: _onSurfaceDark,
      onBackground: _onSurfaceDark,
      onError: Colors.white,
    ),
  );
}