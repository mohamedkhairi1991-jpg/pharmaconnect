import 'package:flutter/material.dart';

import '../color/pharmaconnect_colors.dart';

abstract final class PharmaConnectTypography {
  static const double minimumTextSize = 11;

  static const TextStyle pageTitle = TextStyle(
    color: PharmaConnectColors.primaryText,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle featureTitle = TextStyle(
    color: PharmaConnectColors.primaryText,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: PharmaConnectColors.primaryText,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cardTitle = TextStyle(
    color: PharmaConnectColors.primaryText,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    color: PharmaConnectColors.primaryText,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle supporting = TextStyle(
    color: PharmaConnectColors.secondaryText,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    color: PharmaConnectColors.primaryText,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle auxiliary = TextStyle(
    color: PharmaConnectColors.secondaryText,
    fontSize: minimumTextSize,
    height: 16 / minimumTextSize,
    fontWeight: FontWeight.w500,
  );

  static const List<TextStyle> all = <TextStyle>[
    pageTitle,
    featureTitle,
    sectionTitle,
    cardTitle,
    body,
    supporting,
    label,
    auxiliary,
  ];

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      color: PharmaConnectColors.primaryText,
      fontSize: 36,
      height: 44 / 36,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: TextStyle(
      color: PharmaConnectColors.primaryText,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: pageTitle,
    headlineLarge: pageTitle,
    headlineMedium: TextStyle(
      color: PharmaConnectColors.primaryText,
      fontSize: 24,
      height: 30 / 24,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: featureTitle,
    titleLarge: sectionTitle,
    titleMedium: cardTitle,
    titleSmall: TextStyle(
      color: PharmaConnectColors.primaryText,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: PharmaConnectColors.primaryText,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: body,
    bodySmall: supporting,
    labelLarge: label,
    labelMedium: label,
    labelSmall: auxiliary,
  );
}
