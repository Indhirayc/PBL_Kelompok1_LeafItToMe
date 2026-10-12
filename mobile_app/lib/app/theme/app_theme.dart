import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGreen,
      onPrimary: Colors.white,
      secondary: AppColors.darkGreen,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.darkGreen,
      error: AppColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
}
