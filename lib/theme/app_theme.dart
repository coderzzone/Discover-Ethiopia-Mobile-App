import 'package:flutter/material.dart';

ThemeData buildEthioExploreTheme() {
  return _buildTheme(Brightness.light);
}

ThemeData buildEthioExploreDarkTheme() {
  return _buildTheme(Brightness.dark);
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  // ── New "Ethiopian Horizon" palette ──────────────────────────────────────
  // Light: Deep Teal + Warm Amber | Dark: Sky Teal + Peach Amber
  final colorScheme = isDark
      ? ColorScheme.dark(
          primary: const Color(0xFF5BB8E8),
          onPrimary: const Color(0xFF003550),
          primaryContainer: const Color(0xFF1A3F54),
          onPrimaryContainer: const Color(0xFFB8E4FF),
          secondary: const Color(0xFFFFB074),
          onSecondary: const Color(0xFF4A2000),
          secondaryContainer: const Color(0xFF4A2E15),
          onSecondaryContainer: const Color(0xFFFFDCC5),
          tertiary: const Color(0xFF6FD4AE),
          onTertiary: const Color(0xFF003828),
          tertiaryContainer: const Color(0xFF1A3D30),
          onTertiaryContainer: const Color(0xFFB5EFDA),
          error: const Color(0xFFFF6B6B),
          onError: const Color(0xFF5C0000),
          surface: const Color(0xFF121517),
          onSurface: const Color(0xFFE4EAEE),
          surfaceContainerHighest: const Color(0xFF2C3238),
          surfaceContainerHigh: const Color(0xFF252B30),
          surfaceContainer: const Color(0xFF1E2428),
          surfaceContainerLow: const Color(0xFF181D21),
          surfaceContainerLowest: const Color(0xFF0E1214),
          outline: const Color(0xFF8EAABB),
          outlineVariant: const Color(0xFF3A4E5A),
        )
      : ColorScheme.light(
          primary: const Color(0xFF1B6B93),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFD0EFFF),
          onPrimaryContainer: const Color(0xFF003550),
          secondary: const Color(0xFFE07B39),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFFFE4CC),
          onSecondaryContainer: const Color(0xFF4A2000),
          tertiary: const Color(0xFF2D8F6F),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFC8F5E3),
          onTertiaryContainer: const Color(0xFF003828),
          error: const Color(0xFFD42F2F),
          onError: Colors.white,
          surface: const Color(0xFFF4F8FB),
          onSurface: const Color(0xFF111820),
          surfaceContainerHighest: const Color(0xFFDDE8EF),
          surfaceContainerHigh: const Color(0xFFE6EFF5),
          surfaceContainer: const Color(0xFFECF3F8),
          surfaceContainerLow: const Color(0xFFF2F7FA),
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          outline: const Color(0xFF6A8FA4),
          outlineVariant: const Color(0xFFBDD4E0),
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    visualDensity: VisualDensity.standard,

    // ── Typography ──────────────────────────────────────────────────────────
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 36, fontWeight: FontWeight.w800,
          letterSpacing: -1.0, height: 1.06),
      headlineMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w800,
          letterSpacing: -0.7, height: 1.1),
      headlineSmall: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700,
          letterSpacing: -0.4, height: 1.2),
      titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          letterSpacing: -0.2, height: 1.25),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge: TextStyle(fontSize: 17, height: 1.6),
      bodyMedium: TextStyle(fontSize: 15, height: 1.5),
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, height: 1.1),
      labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          letterSpacing: 0.6, height: 1.0),
    ),

    // ── AppBar ──────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 72,
    ),

    // ── Navigation Bar ──────────────────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerLowest,
      indicatorColor: colorScheme.primaryContainer,
      labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.6),
        );
      }),
    ),

    // ── Input Fields ────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide:
            BorderSide(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide:
            BorderSide(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      hintStyle:
          TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
    ),

    // ── Cards ───────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLowest,
      elevation: 0,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      shadowColor: colorScheme.onSurface.withValues(alpha: 0.06),
      margin: EdgeInsets.zero,
    ),

    // ── Buttons ─────────────────────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        textStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        textStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.4)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        textStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 0,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),

    // ── Chips ───────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      selectedColor: colorScheme.primaryContainer,
      labelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999)),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),

    // ── Sliders ─────────────────────────────────────────────────────────────
    sliderTheme: SliderThemeData(
      activeTrackColor: colorScheme.primary,
      thumbColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2),
      overlayColor: colorScheme.primary.withValues(alpha: 0.12),
    ),

    // ── Progress Indicators ─────────────────────────────────────────────────
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.primary.withValues(alpha: 0.15),
    ),

    // ── Divider ─────────────────────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color: colorScheme.outline.withValues(alpha: 0.12),
      thickness: 1,
      space: 1,
    ),
  );
}
