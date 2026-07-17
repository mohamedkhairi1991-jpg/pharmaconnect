import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';

void main() {
  group('PharmaConnect dark theme', () {
    final ThemeData theme = PharmaConnectTheme.dark();

    test('uses Material 3 with the approved dark foundation', () {
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, PharmaConnectColors.canvas);
      expect(theme.colorScheme.surface, PharmaConnectColors.surface);
      expect(theme.colorScheme.primary, PharmaConnectColors.primary);
      expect(theme.colorScheme.onSurface, PharmaConnectColors.primaryText);
      expect(theme.colorScheme.error, PharmaConnectColors.error);
    });

    test('configures core components from centralized tokens', () {
      expect(
        theme.appBarTheme.backgroundColor,
        PharmaConnectColors.canvas,
      );
      expect(theme.cardTheme.color, PharmaConnectColors.surface);
      expect(theme.cardTheme.elevation, PharmaConnectElevation.base);
      expect(
        theme.inputDecorationTheme.fillColor,
        PharmaConnectColors.surface,
      );
      expect(
        theme.dialogTheme.backgroundColor,
        PharmaConnectColors.elevatedSurface,
      );
      expect(
        theme.bottomSheetTheme.backgroundColor,
        PharmaConnectColors.elevatedSurface,
      );
      expect(
        theme.snackBarTheme.backgroundColor,
        PharmaConnectColors.elevatedSurface,
      );
      expect(
        theme.progressIndicatorTheme.color,
        PharmaConnectColors.linkFocus,
      );
      expect(
        theme.navigationBarTheme.backgroundColor,
        PharmaConnectColors.surface,
      );
      expect(theme.dividerTheme.color, PharmaConnectColors.subtleBorder);

      final ButtonStyle filledStyle = theme.filledButtonTheme.style!;
      expect(
        filledStyle.backgroundColor!.resolve(const <WidgetState>{}),
        PharmaConnectColors.primary,
      );
      expect(
        filledStyle.backgroundColor!.resolve(const <WidgetState>{
          WidgetState.hovered,
        }),
        PharmaConnectColors.primaryHover,
      );
      expect(
        filledStyle.backgroundColor!.resolve(const <WidgetState>{
          WidgetState.disabled,
        }),
        PharmaConnectColors.disabledContainer,
      );
      expect(
        filledStyle.minimumSize!.resolve(const <WidgetState>{}),
        const Size(
          PharmaConnectSpacing.xxxLarge,
          PharmaConnectSpacing.xxxLarge,
        ),
      );
    });

    test('normal text tokens respect the minimum approved size', () {
      for (final TextStyle style in PharmaConnectTypography.all) {
        expect(
          style.fontSize,
          greaterThanOrEqualTo(PharmaConnectTypography.minimumTextSize),
        );
      }

      final List<TextStyle?> themeStyles = <TextStyle?>[
        theme.textTheme.displayLarge,
        theme.textTheme.displayMedium,
        theme.textTheme.displaySmall,
        theme.textTheme.headlineLarge,
        theme.textTheme.headlineMedium,
        theme.textTheme.headlineSmall,
        theme.textTheme.titleLarge,
        theme.textTheme.titleMedium,
        theme.textTheme.titleSmall,
        theme.textTheme.bodyLarge,
        theme.textTheme.bodyMedium,
        theme.textTheme.bodySmall,
        theme.textTheme.labelLarge,
        theme.textTheme.labelMedium,
        theme.textTheme.labelSmall,
      ];
      for (final TextStyle? style in themeStyles) {
        expect(style?.fontSize, isNotNull);
        expect(
          style!.fontSize,
          greaterThanOrEqualTo(PharmaConnectTypography.minimumTextSize),
        );
      }
    });

    test('important foreground pairs meet normal-text contrast', () {
      expect(
        _contrast(
          PharmaConnectColors.primaryText,
          PharmaConnectColors.canvas,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(
          PharmaConnectColors.secondaryText,
          PharmaConnectColors.canvas,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(
          PharmaConnectColors.primaryText,
          PharmaConnectColors.primary,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(PharmaConnectColors.error, PharmaConnectColors.canvas),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(PharmaConnectColors.success, PharmaConnectColors.canvas),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(PharmaConnectColors.warning, PharmaConnectColors.canvas),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('semantic lifecycle mapping', () {
    test('draft and archived are neutral', () {
      for (final String value in <String>['draft', 'archived']) {
        final PharmaConnectStatusPresentation presentation =
            PharmaConnectSemanticStatusMapper.fromLifecycleValue(value);
        expect(presentation.status, PharmaConnectSemanticStatus.neutral);
        expect(presentation.semanticCategory, 'Neutral');
        expect(presentation.requiresAction, isFalse);
      }
    });

    test('submitted and pending use warning semantics', () {
      for (final String value in <String>['submitted', 'pending']) {
        final PharmaConnectStatusPresentation presentation =
            PharmaConnectSemanticStatusMapper.fromLifecycleValue(value);
        expect(presentation.status, PharmaConnectSemanticStatus.warning);
        expect(presentation.foreground, PharmaConnectColors.warning);
        expect(presentation.semanticCategory, 'Pending review');
      }
    });

    test('changes requested is amber and action-required', () {
      final PharmaConnectStatusPresentation presentation =
          PharmaConnectSemanticStatusMapper.fromLifecycleValue(
            'changes_requested',
          );
      expect(presentation.status, PharmaConnectSemanticStatus.warning);
      expect(presentation.foreground, PharmaConnectColors.warning);
      expect(presentation.semanticCategory, 'Action required');
      expect(presentation.requiresAction, isTrue);
    });

    test('published, approved, and verified use success semantics', () {
      for (final String value in <String>[
        'published',
        'approved',
        'verified',
      ]) {
        final PharmaConnectStatusPresentation presentation =
            PharmaConnectSemanticStatusMapper.fromLifecycleValue(value);
        expect(presentation.status, PharmaConnectSemanticStatus.success);
        expect(presentation.foreground, PharmaConnectColors.success);
        expect(presentation.semanticCategory, 'Success');
      }
    });

    test('hidden, rejected, and error use error semantics', () {
      for (final String value in <String>['hidden', 'rejected', 'error']) {
        final PharmaConnectStatusPresentation presentation =
            PharmaConnectSemanticStatusMapper.fromLifecycleValue(value);
        expect(presentation.status, PharmaConnectSemanticStatus.error);
        expect(presentation.foreground, PharmaConnectColors.error);
        expect(presentation.semanticCategory, 'Error');
      }
    });

    test('loading and unknown values remain unresolved', () {
      for (final String value in <String>['loading', 'unknown_state']) {
        final PharmaConnectStatusPresentation presentation =
            PharmaConnectSemanticStatusMapper.fromLifecycleValue(value);
        expect(presentation.status, PharmaConnectSemanticStatus.unresolved);
        expect(presentation.semanticCategory, 'Unresolved');
      }
    });
  });
}

double _contrast(Color foreground, Color background) {
  final double foregroundLuminance = _relativeLuminance(foreground);
  final double backgroundLuminance = _relativeLuminance(background);
  final double lighter = math.max(foregroundLuminance, backgroundLuminance);
  final double darker = math.min(foregroundLuminance, backgroundLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  return 0.2126 * _linearize(color.r) +
      0.7152 * _linearize(color.g) +
      0.0722 * _linearize(color.b);
}

double _linearize(double channel) {
  if (channel <= 0.04045) {
    return channel / 12.92;
  }
  return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}
