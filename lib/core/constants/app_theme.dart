import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// Professional Theme Configuration
/// Material Design 3 with Custom Brand Identity
///
/// Theme Features:
/// - Material Design 3 components
/// - Consistent color system
/// - Accessible contrast ratios
/// - Smooth animations
/// - Touch-optimized sizing
class AppTheme {
  AppTheme._();

  /// Light theme - Primary app theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLighter,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accentLight,
        error: AppColors.error,
        errorContainer: AppColors.errorLight,
        surface: AppColors.surface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onError: AppColors.onError,
        onSurface: AppColors.onSurface,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
      ),

      // AppBar theme - Clean and modern
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppDimensions.elevation0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h4.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: AppColors.iconOnPrimary,
          size: AppDimensions.iconM,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Card theme - Elevated and rounded
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        surfaceTintColor: AppColors.primary,
        elevation: AppDimensions.cardElevation,
        shadowColor: AppColors.shadowMedium,
        margin: AppDimensions.paddingAllM,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusL,
        ),
      ),

      // Elevated button theme - Primary actions
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonTextPrimary,
          elevation: AppDimensions.elevation2,
          shadowColor: AppColors.shadowMedium,
          padding: AppDimensions.buttonPadding,
          minimumSize:
              Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Filled button theme - Alternative primary actions
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: AppDimensions.elevation0,
          padding: AppDimensions.buttonPadding,
          minimumSize:
              Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Outlined button theme - Secondary actions
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
              color: AppColors.border, width: AppDimensions.borderThin),
          padding: AppDimensions.buttonPadding,
          minimumSize:
              Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),

      // Text button theme - Tertiary actions
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppDimensions.buttonPadding,
          minimumSize:
              Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.iconPrimary,
          minimumSize:
              Size(AppDimensions.iconButtonSize, AppDimensions.iconButtonSize),
          padding: AppDimensions.paddingAllS,
        ),
      ),

      // Input decoration theme - Clean and accessible
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        hoverColor: AppColors.gray100,

        // Default border
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.inputBorder,
            width: AppDimensions.borderThin,
          ),
        ),

        // Enabled border
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.inputBorder,
            width: AppDimensions.borderThin,
          ),
        ),

        // Focused border - Emphasized
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.inputBorderFocused,
            width: AppDimensions.borderThick,
          ),
        ),

        // Error border
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.inputBorderError,
            width: AppDimensions.borderThin,
          ),
        ),

        // Focused error border
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.inputBorderError,
            width: AppDimensions.borderThick,
          ),
        ),

        // Disabled border
        disabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.inputBorderDisabled,
            width: AppDimensions.borderThin,
          ),
        ),

        contentPadding: AppDimensions.inputPadding,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.inputPlaceholder,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppTextStyles.caption.copyWith(
          color: AppColors.error,
        ),
      ),

      // Text theme - Complete typography system
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        titleLarge: AppTextStyles.h4,
        titleMedium: AppTextStyles.h5,
        titleSmall: AppTextStyles.h6,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: AppColors.iconPrimary,
        size: AppDimensions.iconM,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: AppDimensions.dividerThickness,
        space: AppDimensions.spaceM,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray100,
        selectedColor: AppColors.primaryLighter,
        labelStyle: AppTextStyles.labelMedium,
        padding: AppDimensions.paddingAllS,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusS,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppDimensions.dialogElevation,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusL,
        ),
        titleTextStyle: AppTextStyles.h4,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppDimensions.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusTopL,
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.secondary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSecondary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
        actionTextColor: AppColors.primary,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: AppDimensions.listItemPadding,
        minVerticalPadding: AppDimensions.spaceS,
        iconColor: AppColors.iconSecondary,
        textColor: AppColors.textPrimary,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.gray200;
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusXS,
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.gray400;
        }),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppDimensions.elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusL,
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLighter,
        circularTrackColor: AppColors.primaryLighter,
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.gray800,
          borderRadius: AppDimensions.borderRadiusS,
        ),
        textStyle: AppTextStyles.caption.copyWith(
          color: AppColors.white,
        ),
        padding: AppDimensions.paddingAllS,
      ),
    );
  }

  /// Dark theme - Full configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accentLight,
        error: AppColors.error,
        errorContainer: AppColors.errorDark,
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onError: AppColors.onError,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.gray600,
        outlineVariant: AppColors.gray700,
      ),

      // AppBar theme - Dark mode
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: AppDimensions.elevation0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h4.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: AppColors.darkTextPrimary,
          size: AppDimensions.iconM,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Card theme - Dark mode
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: AppColors.primary,
        elevation: AppDimensions.cardElevation,
        shadowColor: AppColors.black.withValues(alpha: 0.3),
        margin: AppDimensions.paddingAllM,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusL,
        ),
      ),

      // Elevated button theme - Dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: AppDimensions.elevation2,
          shadowColor: AppColors.black.withValues(alpha: 0.3),
          padding: AppDimensions.buttonPadding,
          minimumSize:
              Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Filled button theme - Dark mode
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: AppDimensions.elevation0,
          padding: AppDimensions.buttonPadding,
          minimumSize:
              Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Outlined button theme - Dark mode
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
              color: AppColors.gray600, width: AppDimensions.borderThin),
          padding: AppDimensions.buttonPadding,
          minimumSize:
              Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),

      // Text button theme - Dark mode
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppDimensions.buttonPadding,
          minimumSize:
              Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),

      // Icon button theme - Dark mode
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          minimumSize:
              Size(AppDimensions.iconButtonSize, AppDimensions.iconButtonSize),
          padding: AppDimensions.paddingAllS,
        ),
      ),

      // Input decoration theme - Dark mode
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        hoverColor: AppColors.gray800,

        // Default border
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.gray600,
            width: AppDimensions.borderThin,
          ),
        ),

        // Enabled border
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.gray600,
            width: AppDimensions.borderThin,
          ),
        ),

        // Focused border
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderThick,
          ),
        ),

        // Error border
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderThin,
          ),
        ),

        // Focused error border
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderThick,
          ),
        ),

        // Disabled border
        disabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.gray700,
            width: AppDimensions.borderThin,
          ),
        ),

        contentPadding: AppDimensions.inputPadding,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextTertiary,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        errorStyle: AppTextStyles.caption.copyWith(
          color: AppColors.error,
        ),
      ),

      // Text theme - Dark mode
      textTheme:
          GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.darkTextPrimary),
        displayMedium: AppTextStyles.displayMedium
            .copyWith(color: AppColors.darkTextPrimary),
        displaySmall: AppTextStyles.displaySmall
            .copyWith(color: AppColors.darkTextPrimary),
        headlineLarge:
            AppTextStyles.h1.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium:
            AppTextStyles.h2.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall:
            AppTextStyles.h3.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: AppTextStyles.h4.copyWith(color: AppColors.darkTextPrimary),
        titleMedium:
            AppTextStyles.h5.copyWith(color: AppColors.darkTextPrimary),
        titleSmall: AppTextStyles.h6.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
        bodySmall: AppTextStyles.bodySmall
            .copyWith(color: AppColors.darkTextSecondary),
        labelLarge:
            AppTextStyles.labelLarge.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: AppTextStyles.labelMedium
            .copyWith(color: AppColors.darkTextPrimary),
        labelSmall: AppTextStyles.labelSmall
            .copyWith(color: AppColors.darkTextSecondary),
      ),

      // Icon theme - Dark mode
      iconTheme: IconThemeData(
        color: AppColors.darkTextPrimary,
        size: AppDimensions.iconM,
      ),

      // Divider theme - Dark mode
      dividerTheme: DividerThemeData(
        color: AppColors.gray700,
        thickness: AppDimensions.dividerThickness,
        space: AppDimensions.spaceM,
      ),

      // Chip theme - Dark mode
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primaryDark,
        labelStyle: AppTextStyles.labelMedium
            .copyWith(color: AppColors.darkTextPrimary),
        padding: AppDimensions.paddingAllS,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusS,
        ),
      ),

      // Dialog theme - Dark mode
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: AppDimensions.dialogElevation,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusL,
        ),
        titleTextStyle:
            AppTextStyles.h4.copyWith(color: AppColors.darkTextPrimary),
        contentTextStyle: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.darkTextSecondary),
      ),

      // Bottom sheet theme - Dark mode
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: AppDimensions.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusTopL,
        ),
      ),

      // Snackbar theme - Dark mode
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.gray800,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
        actionTextColor: AppColors.primary,
      ),

      // List tile theme - Dark mode
      listTileTheme: ListTileThemeData(
        contentPadding: AppDimensions.listItemPadding,
        minVerticalPadding: AppDimensions.spaceS,
        iconColor: AppColors.darkTextSecondary,
        textColor: AppColors.darkTextPrimary,
      ),

      // Switch theme - Dark mode
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.gray500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return AppColors.gray700;
        }),
      ),

      // Checkbox theme - Dark mode
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusXS,
        ),
      ),

      // Radio theme - Dark mode
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.gray500;
        }),
      ),

      // Floating action button theme - Dark mode
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppDimensions.elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusL,
        ),
      ),

      // Progress indicator theme - Dark mode
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.gray700,
        circularTrackColor: AppColors.gray700,
      ),

      // Tooltip theme - Dark mode
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.gray600,
          borderRadius: AppDimensions.borderRadiusS,
        ),
        textStyle: AppTextStyles.caption.copyWith(
          color: AppColors.white,
        ),
        padding: AppDimensions.paddingAllS,
      ),

      // Bottom navigation bar theme - Dark mode
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: AppDimensions.elevation4,
      ),

      // Navigation bar theme - Dark mode (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryDark,
        elevation: AppDimensions.elevation4,
      ),
    );
  }
}
