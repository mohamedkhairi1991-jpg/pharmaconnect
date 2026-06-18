import 'package:flutter/material.dart';

import '../color/pharmaconnect_colors.dart';

abstract final class PharmaConnectTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: PharmaConnectColors.seed),
      useMaterial3: true,
    );
  }
}
