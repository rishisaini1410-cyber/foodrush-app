import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData forMode(String mode) {
    final accent = mode == 'veg' ? AppColors.vegAccent : AppColors.nonVegAccent;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: ColorScheme.fromSeed(seedColor: accent),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    );
  }
}