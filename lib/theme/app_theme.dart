import 'package:flutter/material.dart';

import '../widgets/ui_components.dart';

ThemeData buildEthioExploreTheme() {
  return _buildTheme(Brightness.light);
}

ThemeData buildEthioExploreDarkTheme() {
  return _buildTheme(Brightness.dark);
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.light(
    primary: isDark ? const Color(0xFFE8A277) : EthioColors.primary,
    onPrimary: Colors.white,
    primaryContainer: isDark ? const Color(0xFF6A3A24) : EthioColors.primaryContainer,
    onPrimaryContainer: isDark ? const Color(0xFFFFDCC8) : EthioColors.onPrimaryContainer,
    secondary: isDark ? const Color(0xFF97C69E) : EthioColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: isDark ? const Color(0xFF2F4C34) : EthioColors.secondaryContainer,
    onSecondaryContainer: isDark ? const Color(0xFFCDE7D0) : EthioColors.onSecondaryContainer,
    tertiary: isDark ? const Color(0xFFD8BD60) : EthioColors.tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: isDark ? const Color(0xFF4D3F00) : EthioColors.tertiaryContainer,
    onTertiaryContainer: isDark ? const Color(0xFFF2E3AA) : EthioColors.onTertiaryContainer,
    error: EthioColors.error,
    onError: Colors.white,
    surface: isDark ? const Color(0xFF15130F) : EthioColors.background,
    onSurface: isDark ? const Color(0xFFF4ECE2) : EthioColors.ink,
    surfaceContainerHighest: isDark ? const Color(0xFF3C362E) : EthioColors.surfaceContainerHigh,
    surfaceContainerHigh: isDark ? const Color(0xFF332D25) : EthioColors.surfaceContainerHigh,
    surfaceContainer: isDark ? const Color(0xFF2A251F) : EthioColors.surfaceContainer,
    surfaceContainerLow: isDark ? const Color(0xFF221D17) : EthioColors.surfaceContainerLow,
    surfaceContainerLowest: isDark ? const Color(0xFF1B1713) : EthioColors.surfaceContainerLowest,
    outline: isDark ? const Color(0xFFA69587) : EthioColors.outline,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    visualDensity: VisualDensity.standard,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -0.9, height: 1.06),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.7, height: 1.1),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.2),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2, height: 1.2),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge: TextStyle(fontSize: 17, height: 1.55),
      bodyMedium: TextStyle(fontSize: 15, height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.1),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, height: 1.0),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 72,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerLowest,
      labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.3),
      ),
      hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.65)),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      shadowColor: colorScheme.onSurface.withValues(alpha: 0.06),
      margin: EdgeInsets.zero,
    ),
  );
}
