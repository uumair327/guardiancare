import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Professional Typography System
/// Based on Material Design 3 Type Scale and Readability Best Practices
/// 
/// Typography Principles:
/// - Font: Poppins (modern, readable, professional)
/// - Scale: Modular scale with 1.25 ratio
/// - Line height: 1.4-1.6 for optimal readability
/// - Letter spacing: Adjusted for each size
/// - Contrast: WCAG AA compliant color combinations
class AppTextStyles {
  AppTextStyles._();

  // Base font family - Poppins for modern, clean look
  static TextStyle get _baseTextStyle => GoogleFonts.poppins(
    letterSpacing: 0,
    height: 1.5,
  );

  // ==================== Display Styles (Hero Text) ====================
  /// Display Large - Hero sections, landing pages
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.12,
        letterSpacing: -0.25,
      );

  /// Display Medium - Large hero text
  static TextStyle get displayMedium => _baseTextStyle.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.16,
        letterSpacing: 0,
      );

  /// Display Small - Smaller hero text
  static TextStyle get displaySmall => _baseTextStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.22,
        letterSpacing: 0,
      );

  // ==================== Headings (Page Titles & Sections) ====================
  /// Heading 1 - Main page titles
  static TextStyle get h1 => _baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
        letterSpacing: 0,
      );

  /// Heading 2 - Section titles
  static TextStyle get h2 => _baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.29,
        letterSpacing: 0,
      );

  /// Heading 3 - Subsection titles
  static TextStyle get h3 => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.33,
        letterSpacing: 0,
      );

  /// Heading 4 - Card titles
  static TextStyle get h4 => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: 0.15,
      );

  /// Heading 5 - Small section headers
  static TextStyle get h5 => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.44,
        letterSpacing: 0.15,
      );

  /// Heading 6 - Smallest headers
  static TextStyle get h6 => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.5,
        letterSpacing: 0.15,
      );

  // ==================== Subtitles (Supporting Text) ====================
  /// Subtitle 1 - Large supporting text
  static TextStyle get subtitle1 => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
        letterSpacing: 0.15,
      );

  /// Subtitle 2 - Small supporting text
  static TextStyle get subtitle2 => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.43,
        letterSpacing: 0.1,
      );

  // ==================== Body Text (Content) ====================
  /// Body Large - Emphasized body text
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
        letterSpacing: 0.5,
      );

  /// Body Medium - Default body text (most readable)
  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.43,
        letterSpacing: 0.25,
      );

  /// Body Small - Compact body text
  static TextStyle get bodySmall => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.33,
        letterSpacing: 0.4,
      );
  
  // Legacy aliases for backward compatibility
  static TextStyle get body1 => bodyLarge;
  static TextStyle get body2 => bodyMedium;
  static TextStyle get body3 => bodySmall;

  // ==================== Label Styles (UI Elements) ====================
  /// Label Large - Large buttons, tabs
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.43,
        letterSpacing: 0.1,
      );

  /// Label Medium - Standard buttons
  static TextStyle get labelMedium => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.33,
        letterSpacing: 0.5,
      );

  /// Label Small - Small buttons, chips
  static TextStyle get labelSmall => _baseTextStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.45,
        letterSpacing: 0.5,
      );

  // ==================== Utility Styles ====================
  /// Button text - Primary actions
  static TextStyle get button => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.43,
        letterSpacing: 0.1,
      );

  /// Button Large - Prominent CTAs
  static TextStyle get buttonLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.5,
        letterSpacing: 0.15,
      );

  /// Caption - Helper text, timestamps
  static TextStyle get caption => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.33,
        letterSpacing: 0.4,
      );

  /// Overline - Labels, categories
  static TextStyle get overline => _baseTextStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.6,
        letterSpacing: 1.5,
        textBaseline: TextBaseline.alphabetic,
      );

  /// Label - Form labels, tags
  static TextStyle get label => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.43,
        letterSpacing: 0.1,
      );

  // ==================== Specialized Styles ====================
  
  /// Link text style
  static TextStyle get link => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        decoration: TextDecoration.underline,
        height: 1.5,
      );

  /// Error text style
  static TextStyle get error => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.error,
        height: 1.4,
      );

  /// Hint text style
  static TextStyle get hint => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textHint,
        height: 1.5,
      );

  /// Input text style
  static TextStyle get input => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// App bar title style
  static TextStyle get appBarTitle => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onPrimary,
        height: 1.2,
      );

  /// Card title style
  static TextStyle get cardTitle => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  /// Dialog title style
  static TextStyle get dialogTitle => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        height: 1.3,
      );

  /// Italic style
  static TextStyle get italic => _baseTextStyle.copyWith(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  /// Bold style
  static TextStyle get bold => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.5,
      );
}
