import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Material 3 "Expressive" theming: seed-driven dynamic colour, generous
/// corner radii and springy, high-contrast surfaces.
/// ---------------------------------------------------------------------------

/// Selectable theme seed colours (the "Setting: colour" feature).
const List<({String en, String zh, Color color})> kSeedPalettes = [
  (en: 'Lavender Dusk', zh: '薰衣草暮色', color: Color(0xFF6750A4)),
  (en: 'Ocean Calm', zh: '深海静谧', color: Color(0xFF00696E)),
  (en: 'Peach Warmth', zh: '暖桃色', color: Color(0xFFB3261E)),
  (en: 'Forest Rest', zh: '森林休憩', color: Color(0xFF3F6B3F)),
  (en: 'Golden Hour', zh: '黄金时刻', color: Color(0xFF8A5A00)),
  (en: 'Iris Night', zh: '鸢尾之夜', color: Color(0xFF3D5AFE)),
];

class AppTheme {
  static Color seed(int index) =>
      kSeedPalettes[index % kSeedPalettes.length].color;

  static ThemeData build(int seedIndex, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed(seedIndex),
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.expressive,
    );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorShape: const StadiumBorder(),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      sliderTheme: base.sliderTheme.copyWith(
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        trackHeight: 10,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        iconColor: scheme.primary,
      ),
    );
  }

  /// Big, friendly display style used on hero headers.
  static TextStyle display(ThemeData t) => t.textTheme.displaySmall!.copyWith(
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );
}
