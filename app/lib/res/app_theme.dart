import 'package:flutter/material.dart';

import 'package:myapp/res/app_colors.dart';

class AppTheme {
  const AppTheme._();

  /// 获取应用浅色主题配置。
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'monospace',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          background: AppColors.background,
          surface: AppColors.surface,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF101E33),
          foregroundColor: AppColors.textPrimary,
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: const Color(0xFF04151D),
          ),
        ),
      );
}
