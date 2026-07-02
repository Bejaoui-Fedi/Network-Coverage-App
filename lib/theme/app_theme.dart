import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFFF7900);
  static const Color darkOrange = Color(0xFFE56900);
  static const Color lightOrange = Color(0xFFFFAA55);

  // Dark theme colors
  static const Color darkBg = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);
  static const Color darkCard = Color(0xFF232635);
  static const Color darkBorder = Color(0xFF2E3247);

  // Light theme colors
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        brightness: Brightness.light,
        primary: primaryOrange,
        secondary: darkOrange,
        surface: lightSurface,
        background: lightBg,
      ),
      scaffoldBackgroundColor: lightBg,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE8EBF0), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: lightSurface,
        selectedIconTheme: IconThemeData(color: primaryOrange),
        selectedLabelTextStyle: TextStyle(
          color: primaryOrange,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedIconTheme: IconThemeData(color: Color(0xFF9CA3AF)),
        unselectedLabelTextStyle: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 12,
        ),
        indicatorColor: Color(0xFFFFF3E8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryOrange,
        unselectedItemColor: Color(0xFF9CA3AF),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEF0F4),
        thickness: 1,
        space: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827)),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827), fontSize: 22),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827), fontSize: 18),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827), fontSize: 16),
        titleSmall: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF6B7280), fontSize: 12),
        bodyMedium: TextStyle(color: Color(0xFF374151), fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        brightness: Brightness.dark,
        primary: primaryOrange,
        secondary: lightOrange,
        surface: darkSurface,
        background: darkBg,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: darkSurface,
        selectedIconTheme: const IconThemeData(color: primaryOrange),
        selectedLabelTextStyle: const TextStyle(
          color: primaryOrange,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedIconTheme: const IconThemeData(color: Color(0xFF6B7280)),
        unselectedLabelTextStyle: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
        ),
        indicatorColor: primaryOrange.withOpacity(0.15),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryOrange,
        unselectedItemColor: const Color(0xFF6B7280),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 22),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
        titleSmall: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF), fontSize: 12),
        bodyMedium: TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
      ),
    );
  }
}
