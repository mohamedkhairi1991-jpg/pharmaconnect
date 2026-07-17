import 'package:flutter/material.dart';

import '../border/pharmaconnect_borders.dart';
import '../color/pharmaconnect_colors.dart';
import '../elevation/pharmaconnect_elevation.dart';
import '../radius/pharmaconnect_radii.dart';
import '../spacing/pharmaconnect_spacing.dart';
import '../typography/pharmaconnect_typography.dart';

abstract final class PharmaConnectTheme {
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: PharmaConnectColors.primary,
    onPrimary: PharmaConnectColors.primaryText,
    primaryContainer: PharmaConnectColors.deepBlue,
    onPrimaryContainer: PharmaConnectColors.primaryText,
    secondary: PharmaConnectColors.linkFocus,
    onSecondary: PharmaConnectColors.canvas,
    secondaryContainer: PharmaConnectColors.elevatedSurface,
    onSecondaryContainer: PharmaConnectColors.primaryText,
    tertiary: PharmaConnectColors.success,
    onTertiary: PharmaConnectColors.canvas,
    tertiaryContainer: PharmaConnectColors.successContainer,
    onTertiaryContainer: PharmaConnectColors.success,
    error: PharmaConnectColors.error,
    onError: PharmaConnectColors.canvas,
    errorContainer: PharmaConnectColors.errorContainer,
    onErrorContainer: PharmaConnectColors.error,
    surface: PharmaConnectColors.surface,
    onSurface: PharmaConnectColors.primaryText,
    surfaceDim: PharmaConnectColors.canvas,
    surfaceBright: PharmaConnectColors.elevatedSurface,
    surfaceContainerLowest: PharmaConnectColors.canvas,
    surfaceContainerLow: PharmaConnectColors.surface,
    surfaceContainer: PharmaConnectColors.surface,
    surfaceContainerHigh: PharmaConnectColors.elevatedSurface,
    surfaceContainerHighest: PharmaConnectColors.elevatedSurface,
    onSurfaceVariant: PharmaConnectColors.secondaryText,
    outline: PharmaConnectColors.strongBorder,
    outlineVariant: PharmaConnectColors.subtleBorder,
    shadow: PharmaConnectColors.shadow,
    scrim: PharmaConnectColors.scrim,
    inverseSurface: PharmaConnectColors.primaryText,
    onInverseSurface: PharmaConnectColors.canvas,
    inversePrimary: PharmaConnectColors.deepBlue,
    surfaceTint: PharmaConnectColors.transparent,
  );

  static ThemeData dark() {
    final InputDecorationThemeData inputTheme = _inputTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: PharmaConnectColors.canvas,
      canvasColor: PharmaConnectColors.canvas,
      cardColor: PharmaConnectColors.surface,
      dividerColor: PharmaConnectColors.subtleBorder,
      disabledColor: PharmaConnectColors.disabledText,
      focusColor: PharmaConnectColors.linkFocus.withValues(alpha: 0.16),
      hoverColor: PharmaConnectColors.primaryHover.withValues(alpha: 0.12),
      highlightColor: PharmaConnectColors.primaryHover.withValues(alpha: 0.12),
      splashColor: PharmaConnectColors.primaryHover.withValues(alpha: 0.16),
      shadowColor: PharmaConnectColors.shadow,
      textTheme: PharmaConnectTypography.textTheme,
      primaryTextTheme: PharmaConnectTypography.textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: _appBarTheme(),
      cardTheme: _cardTheme(),
      filledButtonTheme: _filledButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      floatingActionButtonTheme: _floatingActionButtonTheme(),
      inputDecorationTheme: inputTheme,
      dropdownMenuTheme: _dropdownMenuTheme(inputTheme),
      checkboxTheme: _checkboxTheme(),
      radioTheme: _radioTheme(),
      switchTheme: _switchTheme(),
      chipTheme: _chipTheme(),
      dialogTheme: _dialogTheme(),
      bottomSheetTheme: _bottomSheetTheme(),
      snackBarTheme: _snackBarTheme(),
      progressIndicatorTheme: _progressIndicatorTheme(),
      dividerTheme: _dividerTheme(),
      tooltipTheme: _tooltipTheme(),
      navigationBarTheme: _navigationBarTheme(),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(),
      navigationRailTheme: _navigationRailTheme(),
      textSelectionTheme: _textSelectionTheme(),
      iconTheme: const IconThemeData(color: PharmaConnectColors.secondaryText),
      primaryIconTheme: const IconThemeData(
        color: PharmaConnectColors.primaryText,
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: PharmaConnectColors.seed),
      useMaterial3: true,
    );
  }

  static AppBarThemeData _appBarTheme() {
    return const AppBarThemeData(
      backgroundColor: PharmaConnectColors.canvas,
      foregroundColor: PharmaConnectColors.primaryText,
      surfaceTintColor: PharmaConnectColors.transparent,
      shadowColor: PharmaConnectColors.transparent,
      elevation: PharmaConnectElevation.base,
      scrolledUnderElevation: PharmaConnectElevation.base,
      centerTitle: false,
      titleTextStyle: PharmaConnectTypography.sectionTitle,
      toolbarHeight: PharmaConnectSpacing.xxxLarge + PharmaConnectSpacing.medium,
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      color: PharmaConnectColors.surface,
      surfaceTintColor: PharmaConnectColors.transparent,
      shadowColor: PharmaConnectColors.transparent,
      elevation: PharmaConnectElevation.base,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        side: const BorderSide(
          color: PharmaConnectColors.subtleBorder,
          width: PharmaConnectBorders.standard,
        ),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme() {
    return FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(
          Size(PharmaConnectSpacing.xxxLarge, PharmaConnectSpacing.xxxLarge),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            horizontal: PharmaConnectSpacing.roomy,
            vertical: PharmaConnectSpacing.compact,
          ),
        ),
        textStyle: const WidgetStatePropertyAll<TextStyle>(
          PharmaConnectTypography.label,
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return PharmaConnectColors.disabledContainer;
            }
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered)) {
              return PharmaConnectColors.primaryHover;
            }
            return PharmaConnectColors.primary;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.disabled)
              ? PharmaConnectColors.disabledText
              : PharmaConnectColors.primaryText,
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.focused)
              ? PharmaConnectColors.linkFocus.withValues(alpha: 0.16)
              : null,
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
          ),
        ),
        elevation: const WidgetStatePropertyAll<double>(
          PharmaConnectElevation.base,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(
          Size(PharmaConnectSpacing.xxxLarge, PharmaConnectSpacing.xxxLarge),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            horizontal: PharmaConnectSpacing.roomy,
            vertical: PharmaConnectSpacing.compact,
          ),
        ),
        textStyle: const WidgetStatePropertyAll<TextStyle>(
          PharmaConnectTypography.label,
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.disabled)
              ? PharmaConnectColors.disabledText
              : PharmaConnectColors.linkFocus,
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.selected)
              ? PharmaConnectColors.elevatedSurface
              : PharmaConnectColors.transparent,
        ),
        side: WidgetStateProperty.resolveWith<BorderSide>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(
                color: PharmaConnectColors.subtleBorder,
                width: PharmaConnectBorders.standard,
              );
            }
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(
                color: PharmaConnectColors.linkFocus,
                width: PharmaConnectBorders.focus,
              );
            }
            return const BorderSide(
              color: PharmaConnectColors.strongBorder,
              width: PharmaConnectBorders.standard,
            );
          },
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
          ),
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(
          Size(PharmaConnectSpacing.xxxLarge, PharmaConnectSpacing.xxxLarge),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: PharmaConnectSpacing.medium),
        ),
        textStyle: const WidgetStatePropertyAll<TextStyle>(
          PharmaConnectTypography.label,
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => states.contains(WidgetState.disabled)
              ? PharmaConnectColors.disabledText
              : PharmaConnectColors.linkFocus,
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)
              ? PharmaConnectColors.linkFocus.withValues(alpha: 0.12)
              : null,
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
          ),
        ),
      ),
    );
  }

  static FloatingActionButtonThemeData _floatingActionButtonTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: PharmaConnectColors.primary,
      foregroundColor: PharmaConnectColors.primaryText,
      hoverColor: PharmaConnectColors.primaryHover,
      focusColor: PharmaConnectColors.linkFocus,
      elevation: PharmaConnectElevation.elevated,
      focusElevation: PharmaConnectElevation.elevated,
      hoverElevation: PharmaConnectElevation.elevated,
      highlightElevation: PharmaConnectElevation.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(PharmaConnectRadii.control),
        ),
      ),
    );
  }

  static InputDecorationThemeData _inputTheme() {
    const BorderSide standardSide = BorderSide(
      color: PharmaConnectColors.strongBorder,
      width: PharmaConnectBorders.standard,
    );
    const BorderSide focusedSide = BorderSide(
      color: PharmaConnectColors.linkFocus,
      width: PharmaConnectBorders.focus,
    );
    const BorderSide errorSide = BorderSide(
      color: PharmaConnectColors.error,
      width: PharmaConnectBorders.standard,
    );
    const BorderSide focusedErrorSide = BorderSide(
      color: PharmaConnectColors.error,
      width: PharmaConnectBorders.focus,
    );
    const BorderSide disabledSide = BorderSide(
      color: PharmaConnectColors.subtleBorder,
      width: PharmaConnectBorders.standard,
    );

    return InputDecorationThemeData(
      filled: true,
      fillColor: PharmaConnectColors.surface,
      hoverColor: PharmaConnectColors.elevatedSurface,
      focusColor: PharmaConnectColors.linkFocus,
      iconColor: PharmaConnectColors.secondaryText,
      prefixIconColor: PharmaConnectColors.secondaryText,
      suffixIconColor: PharmaConnectColors.secondaryText,
      labelStyle: PharmaConnectTypography.supporting,
      floatingLabelStyle: PharmaConnectTypography.label.copyWith(
        color: PharmaConnectColors.linkFocus,
      ),
      hintStyle: PharmaConnectTypography.supporting,
      helperStyle: PharmaConnectTypography.supporting,
      errorStyle: PharmaConnectTypography.supporting.copyWith(
        color: PharmaConnectColors.error,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PharmaConnectSpacing.medium,
        vertical: PharmaConnectSpacing.medium,
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(PharmaConnectRadii.control),
        ),
        borderSide: standardSide,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(PharmaConnectRadii.control),
        ),
        borderSide: standardSide,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(PharmaConnectRadii.control),
        ),
        borderSide: focusedSide,
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(PharmaConnectRadii.control),
        ),
        borderSide: errorSide,
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(PharmaConnectRadii.control),
        ),
        borderSide: focusedErrorSide,
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(PharmaConnectRadii.control),
        ),
        borderSide: disabledSide,
      ),
    );
  }

  static DropdownMenuThemeData _dropdownMenuTheme(
    InputDecorationThemeData inputTheme,
  ) {
    return DropdownMenuThemeData(
      textStyle: PharmaConnectTypography.body,
      inputDecorationTheme: inputTheme,
      menuStyle: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll<Color>(
          PharmaConnectColors.elevatedSurface,
        ),
        surfaceTintColor: const WidgetStatePropertyAll<Color>(
          PharmaConnectColors.transparent,
        ),
        elevation: const WidgetStatePropertyAll<double>(
          PharmaConnectElevation.overlay,
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
            side: const BorderSide(
              color: PharmaConnectColors.strongBorder,
              width: PharmaConnectBorders.standard,
            ),
          ),
        ),
      ),
    );
  }

  static CheckboxThemeData _checkboxTheme() {
    return CheckboxThemeData(
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      checkColor: const WidgetStatePropertyAll<Color>(
        PharmaConnectColors.primaryText,
      ),
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return PharmaConnectColors.disabledContainer;
          }
          if (states.contains(WidgetState.selected)) {
            return PharmaConnectColors.primary;
          }
          return PharmaConnectColors.transparent;
        },
      ),
      side: const BorderSide(
        color: PharmaConnectColors.strongBorder,
        width: PharmaConnectBorders.standard,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PharmaConnectRadii.control / 2),
      ),
    );
  }

  static RadioThemeData _radioTheme() {
    return RadioThemeData(
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return PharmaConnectColors.disabledText;
          }
          if (states.contains(WidgetState.selected)) {
            return PharmaConnectColors.linkFocus;
          }
          return PharmaConnectColors.strongBorder;
        },
      ),
    );
  }

  static SwitchThemeData _switchTheme() {
    return SwitchThemeData(
      materialTapTargetSize: MaterialTapTargetSize.padded,
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return PharmaConnectColors.disabledText;
          }
          return states.contains(WidgetState.selected)
              ? PharmaConnectColors.primaryText
              : PharmaConnectColors.secondaryText;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return PharmaConnectColors.disabledContainer;
          }
          return states.contains(WidgetState.selected)
              ? PharmaConnectColors.primary
              : PharmaConnectColors.elevatedSurface;
        },
      ),
      trackOutlineColor: const WidgetStatePropertyAll<Color>(
        PharmaConnectColors.strongBorder,
      ),
    );
  }

  static ChipThemeData _chipTheme() {
    return ChipThemeData(
      backgroundColor: PharmaConnectColors.surface,
      selectedColor: PharmaConnectColors.deepBlue,
      disabledColor: PharmaConnectColors.disabledContainer,
      checkmarkColor: PharmaConnectColors.primaryText,
      labelStyle: PharmaConnectTypography.label,
      secondaryLabelStyle: PharmaConnectTypography.label,
      side: const BorderSide(
        color: PharmaConnectColors.strongBorder,
        width: PharmaConnectBorders.standard,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(
        horizontal: PharmaConnectSpacing.compact,
        vertical: PharmaConnectSpacing.small,
      ),
    );
  }

  static DialogThemeData _dialogTheme() {
    return DialogThemeData(
      backgroundColor: PharmaConnectColors.elevatedSurface,
      surfaceTintColor: PharmaConnectColors.transparent,
      shadowColor: PharmaConnectColors.shadow,
      elevation: PharmaConnectElevation.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PharmaConnectRadii.dialog),
        side: const BorderSide(
          color: PharmaConnectColors.subtleBorder,
          width: PharmaConnectBorders.standard,
        ),
      ),
      titleTextStyle: PharmaConnectTypography.featureTitle,
      contentTextStyle: PharmaConnectTypography.body,
    );
  }

  static BottomSheetThemeData _bottomSheetTheme() {
    return const BottomSheetThemeData(
      backgroundColor: PharmaConnectColors.elevatedSurface,
      modalBackgroundColor: PharmaConnectColors.elevatedSurface,
      surfaceTintColor: PharmaConnectColors.transparent,
      shadowColor: PharmaConnectColors.shadow,
      modalBarrierColor: PharmaConnectColors.scrim,
      elevation: PharmaConnectElevation.overlay,
      modalElevation: PharmaConnectElevation.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PharmaConnectRadii.dialog),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: PharmaConnectColors.strongBorder,
      dragHandleSize: Size(
        PharmaConnectSpacing.xxLarge,
        PharmaConnectSpacing.xSmall,
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme() {
    return SnackBarThemeData(
      backgroundColor: PharmaConnectColors.elevatedSurface,
      actionTextColor: PharmaConnectColors.linkFocus,
      disabledActionTextColor: PharmaConnectColors.disabledText,
      contentTextStyle: PharmaConnectTypography.body,
      elevation: PharmaConnectElevation.overlay,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
        side: const BorderSide(
          color: PharmaConnectColors.strongBorder,
          width: PharmaConnectBorders.standard,
        ),
      ),
    );
  }

  static ProgressIndicatorThemeData _progressIndicatorTheme() {
    return const ProgressIndicatorThemeData(
      color: PharmaConnectColors.linkFocus,
      linearTrackColor: PharmaConnectColors.elevatedSurface,
      circularTrackColor: PharmaConnectColors.elevatedSurface,
    );
  }

  static DividerThemeData _dividerTheme() {
    return const DividerThemeData(
      color: PharmaConnectColors.subtleBorder,
      thickness: PharmaConnectBorders.standard,
      space: PharmaConnectSpacing.medium,
    );
  }

  static TooltipThemeData _tooltipTheme() {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: PharmaConnectColors.tooltip,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
        border: Border.all(
          color: PharmaConnectColors.strongBorder,
          width: PharmaConnectBorders.standard,
        ),
      ),
      textStyle: PharmaConnectTypography.auxiliary.copyWith(
        color: PharmaConnectColors.primaryText,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: PharmaConnectSpacing.compact,
        vertical: PharmaConnectSpacing.small,
      ),
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(seconds: 3),
    );
  }

  static NavigationBarThemeData _navigationBarTheme() {
    return NavigationBarThemeData(
      height: PharmaConnectSpacing.xxxLarge + PharmaConnectSpacing.medium,
      backgroundColor: PharmaConnectColors.surface,
      surfaceTintColor: PharmaConnectColors.transparent,
      indicatorColor: PharmaConnectColors.deepBlue,
      elevation: PharmaConnectElevation.base,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) => PharmaConnectTypography.label.copyWith(
          color: states.contains(WidgetState.selected)
              ? PharmaConnectColors.primaryText
              : PharmaConnectColors.secondaryText,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
        (Set<WidgetState> states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? PharmaConnectColors.linkFocus
              : PharmaConnectColors.secondaryText,
        ),
      ),
    );
  }

  static BottomNavigationBarThemeData _bottomNavigationBarTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: PharmaConnectColors.surface,
      selectedItemColor: PharmaConnectColors.linkFocus,
      unselectedItemColor: PharmaConnectColors.secondaryText,
      selectedLabelStyle: PharmaConnectTypography.label,
      unselectedLabelStyle: PharmaConnectTypography.auxiliary,
      elevation: PharmaConnectElevation.base,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    );
  }

  static NavigationRailThemeData _navigationRailTheme() {
    return NavigationRailThemeData(
      backgroundColor: PharmaConnectColors.surface,
      elevation: PharmaConnectElevation.base,
      indicatorColor: PharmaConnectColors.deepBlue,
      selectedIconTheme: const IconThemeData(
        color: PharmaConnectColors.linkFocus,
      ),
      unselectedIconTheme: const IconThemeData(
        color: PharmaConnectColors.secondaryText,
      ),
      selectedLabelTextStyle: PharmaConnectTypography.label,
      unselectedLabelTextStyle: PharmaConnectTypography.auxiliary,
      useIndicator: true,
      minWidth: PharmaConnectSpacing.xxxLarge + PharmaConnectSpacing.medium,
    );
  }

  static TextSelectionThemeData _textSelectionTheme() {
    return TextSelectionThemeData(
      cursorColor: PharmaConnectColors.linkFocus,
      selectionColor: PharmaConnectColors.linkFocus.withValues(alpha: 0.32),
      selectionHandleColor: PharmaConnectColors.linkFocus,
    );
  }
}
