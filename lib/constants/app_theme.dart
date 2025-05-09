import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.accentCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentCyan,
        secondary: AppColors.secondaryGrey,
        surface: AppColors.darkBackground,
        surfaceTint: AppColors.cardDarkBackground,
        error: AppColors.errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkTextColor),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(color: AppColors.darkTextColor),
        bodyMedium: const TextStyle(color: AppColors.darkTextColor),
        titleLarge: const TextStyle(color: AppColors.darkTextColor, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardDarkBackground,
        elevation: AppDimensions.elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDarkBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.accentCyan, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentCyan,
          foregroundColor: Colors.white,
          elevation: AppDimensions.elevationS,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeightM),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          side: const BorderSide(color: AppColors.accentCyan),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeightM),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentCyan,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBackground,
        selectedItemColor: AppColors.accentCyan,
        unselectedItemColor: AppColors.secondaryGrey,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: AppColors.accentCyan,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentCyan,
        secondary: AppColors.secondaryGrey,
        surface: Colors.white,
        surfaceTint: AppColors.cardLightBackground,
        error: AppColors.errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightTextColor),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: const TextStyle(color: AppColors.lightTextColor),
        bodyMedium: const TextStyle(color: AppColors.lightTextColor),
        titleLarge: const TextStyle(color: AppColors.lightTextColor, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardLightBackground,
        elevation: AppDimensions.elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardLightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.accentCyan, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentCyan,
          foregroundColor: Colors.white,
          elevation: AppDimensions.elevationS,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeightM),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          side: const BorderSide(color: AppColors.accentCyan),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeightM),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentCyan,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.accentCyan,
        unselectedItemColor: AppColors.secondaryGrey,
      ),
    );
  }
}
