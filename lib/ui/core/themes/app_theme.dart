import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';

/// App theme built from the ImobiBrasil tokens.
///
/// Contrast decisions (see the `imobibrasil-design` skill): green surfaces
/// that carry text use brand600, not brand500; error messages use
/// textSecondary, and only borders and icons use danger.
abstract final class AppTheme {
  static const _buttonRadius = BorderRadius.all(Radius.circular(8));
  static const _cardRadius = BorderRadius.all(Radius.circular(16));
  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: _buttonRadius,
  );

  static const _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.brand600,
    onPrimary: Colors.white,
    primaryContainer: AppColors.brand50,
    onPrimaryContainer: AppColors.brand700,
    secondary: AppColors.accentBlue,
    onSecondary: AppColors.text,
    tertiary: AppColors.accentYellow,
    onTertiary: AppColors.text,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.muted,
    outlineVariant: AppColors.border,
  );

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: _buttonRadius,
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData get light {
    final base = ThemeData(colorScheme: _colorScheme, fontFamily: 'Inter');

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brand600,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.brand800,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          // "Salvando…" keeps the button disabled; brand700 keeps it readable.
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.pressed) ||
                    states.contains(WidgetState.disabled)
                ? AppColors.brand700
                : AppColors.brand600,
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          minimumSize: const WidgetStatePropertyAll(Size(64, 44)),
          shape: const WidgetStatePropertyAll(_buttonShape),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand600,
          side: const BorderSide(color: AppColors.brand600),
          minimumSize: const Size(64, 44),
          shape: _buttonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand600,
          minimumSize: const Size(64, 44),
          shape: _buttonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.muted),
        errorStyle: const TextStyle(color: AppColors.textSecondary),
        border: _inputBorder(AppColors.muted),
        enabledBorder: _inputBorder(AppColors.muted),
        focusedBorder: _inputBorder(AppColors.brand500, width: 2),
        errorBorder: _inputBorder(AppColors.danger, width: 2),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 2),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: _cardRadius,
          side: BorderSide(color: AppColors.border),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.brand50
                : AppColors.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.brand700
                : AppColors.textSecondary,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.muted),
          ),
          // Tighter than the default so the check mark + label fit on narrow
          // screens and with large system fonts.
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 8),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brand500,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.text,
        contentTextStyle: TextStyle(color: Colors.white, fontFamily: 'Inter'),
        actionTextColor: AppColors.brand50,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: _buttonRadius),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: _cardRadius),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    );
  }
}
