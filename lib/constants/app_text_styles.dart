import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get heading1Dark => GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextColor,
  );

  static TextStyle get heading1Light => GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextColor,
  );

  static TextStyle get heading2Dark => GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextColor,
  );

  static TextStyle get heading2Light => GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextColor,
  );

  static TextStyle get bodyDark => GoogleFonts.roboto(
    fontSize: 16,
    color: AppColors.darkTextColor,
  );

  static TextStyle get bodyLight => GoogleFonts.roboto(
    fontSize: 16,
    color: AppColors.lightTextColor,
  );

  static TextStyle get captionDark => GoogleFonts.roboto(
    fontSize: 14,
    color: AppColors.secondaryGrey,
  );

  static TextStyle get captionLight => GoogleFonts.roboto(
    fontSize: 14,
    color: AppColors.secondaryGrey,
  );

  static TextStyle get buttonText => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle get smallButtonText => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}
