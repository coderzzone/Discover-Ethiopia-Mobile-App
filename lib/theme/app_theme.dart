import 'package:flutter/material.dart';

import '../widgets/ui_components.dart';

ThemeData buildEthioExploreTheme() {
  final colorScheme = ColorScheme.light(
    primary: EthioColors.primary,
    onPrimary: Colors.white,
    primaryContainer: EthioColors.primaryContainer,
    onPrimaryContainer: EthioColors.onPrimaryContainer,
    secondary: EthioColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: EthioColors.secondaryContainer,
    onSecondaryContainer: EthioColors.onSecondaryContainer,
    tertiary: EthioColors.tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: EthioColors.tertiaryContainer,
    onTertiaryContainer: EthioColors.onTertiaryContainer,
    error: EthioColors.error,
    onError: Colors.white,
    surface: EthioColors.background,
    onSurface: EthioColors.ink,
    surfaceContainerHighest: EthioColors.surfaceContainerHigh,
    surfaceContainerHigh: EthioColors.surfaceContainerHigh,
    surfaceContainer: EthioColors.surfaceContainer,
    surfaceContainerLow: EthioColors.surfaceContainerLow,
    surfaceContainerLowest: EthioColors.surfaceContainerLowest,
    outline: EthioColors.outline,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: EthioColors.background,
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
    appBarTheme: const AppBarTheme(
      backgroundColor: EthioColors.background,
      foregroundColor: EthioColors.ink,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 72,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: EthioColors.surfaceContainerLowest,
      labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? EthioColors.primary : EthioColors.mutedInk,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: EthioColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: EthioColors.outline.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: EthioColors.outline.withValues(alpha: 0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: EthioColors.primary, width: 1.3),
      ),
      hintStyle: TextStyle(color: EthioColors.mutedInk.withValues(alpha: 0.65)),
    ),
    cardTheme: CardThemeData(
      color: EthioColors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      shadowColor: EthioColors.ink.withValues(alpha: 0.06),
      margin: EdgeInsets.zero,
    ),
  );
}
