import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'clay_tokens.dart';

const _fontFamily = 'Nunito';

/// Nunito is bundled as a variable font, so weight must be applied through
/// the `wght` axis as well as [FontWeight] (for platform fallbacks).
TextStyle _style(double size, int weight, Color color, {double height = 1.3, double spacing = 0}) {
  return TextStyle(
    fontFamily: _fontFamily,
    fontSize: size,
    height: height,
    letterSpacing: spacing,
    color: color,
    fontWeight: FontWeight.values[(weight ~/ 100 - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight.toDouble())],
  );
}

extension TextStyleWeight on TextStyle {
  /// Use instead of `copyWith(fontWeight:)` so the variable font axis updates.
  TextStyle weight(int w) => copyWith(
    fontWeight: FontWeight.values[(w ~/ 100 - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', w.toDouble())],
  );
}

abstract final class AppTheme {
  static ThemeData light() => _build(ClayTheme.light, Brightness.light);
  static ThemeData dark() => _build(ClayTheme.dark, Brightness.dark);

  static ThemeData _build(ClayTheme clay, Brightness brightness) {
    final primary = clay.textPrimary;
    final secondary = clay.textSecondary;

    final textTheme = TextTheme(
      displaySmall: _style(32, 800, primary, height: 1.15, spacing: -0.5),
      headlineMedium: _style(26, 800, primary, height: 1.2, spacing: -0.3),
      headlineSmall: _style(22, 800, primary, height: 1.25),
      titleLarge: _style(19, 800, primary),
      titleMedium: _style(16, 700, primary),
      titleSmall: _style(14, 700, primary),
      bodyLarge: _style(16, 500, primary, height: 1.55),
      bodyMedium: _style(14.5, 500, primary, height: 1.5),
      bodySmall: _style(13, 500, secondary, height: 1.45),
      labelLarge: _style(15, 800, primary, spacing: 0.2),
      labelMedium: _style(13, 700, secondary, spacing: 0.2),
      labelSmall: _style(11.5, 800, secondary, spacing: 0.6),
    );

    final scheme = ColorScheme(
      brightness: brightness,
      primary: clay.brand,
      onPrimary: clay.onBrand,
      secondary: clay.accent,
      onSecondary: clay.onAccent,
      error: clay.critical,
      onError: clay.onCritical,
      surface: clay.surface,
      onSurface: clay.textPrimary,
      onSurfaceVariant: clay.textSecondary,
      surfaceContainerHighest: clay.surfaceSunken,
      outline: clay.textSecondary.withValues(alpha: 0.4),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: clay.background,
      extensions: [clay],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: clay.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: clay.textPrimary,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: clay.brand,
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: clay.onBrand),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClayTheme.radiusSm)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: clay.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClayTheme.radiusLg)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: clay.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(ClayTheme.radiusLg)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: clay.surfaceSunken,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: textTheme.bodyMedium!.copyWith(color: clay.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ClayTheme.radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ClayTheme.radiusSm),
          borderSide: BorderSide(color: clay.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ClayTheme.radiusSm),
          borderSide: BorderSide(color: clay.critical, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ClayTheme.radiusSm),
          borderSide: BorderSide(color: clay.critical, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? clay.onAccent : clay.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? clay.accent : clay.surfaceSunken,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? clay.accent : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(clay.onAccent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: clay.accent,
        inactiveTrackColor: clay.surfaceSunken,
        thumbColor: clay.accent,
        overlayColor: clay.accent.withValues(alpha: 0.15),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: clay.accent),
      dividerTheme: DividerThemeData(color: clay.textSecondary.withValues(alpha: 0.15), space: 1),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
