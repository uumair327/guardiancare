import 'package:flutter/material.dart';

// Primary Colors
const tPrimaryColor = Color(0xFFEF4934); // Primary brand color
const tPrimaryLight = Color(0xFFFF8A80); // Lighter shade of primary
const tPrimaryDark = Color(0xFFB61827); // Darker shade of primary

// Secondary Colors
const tSecondaryColor = Color(0xFF424242); // Dark gray
const tSecondaryLight = Color(0xFF6D6D6D); // Lighter gray
const tSecondaryDark = Color(0xFF1B1B1B); // Darker gray

// Accent Colors
const tAccentColor = Color(0xFFEF4934); // Same as primary for consistency
const tAccentLight = Color(0xFFFF8A80); // Lighter accent
const tAccentDark = Color(0xFFB61827); // Darker accent

// Background Colors
const tBackgroundColor = Color(0xFFFFFFFF); // White background
const tSurfaceColor = Color(0xFFF5F5F5); // Light gray surface
const tCardBgColor = Color(0xFFFFFFFF); // Card background
const tScaffoldBackground = Color(0xFFFAFAFA); // Scaffold background

// Text Colors
const tTextPrimary = Color(0xFF212121); // High emphasis text
const tTextSecondary = Color(0xDE000000); // Medium emphasis text
const tTextHint = Color(0x61000000); // Hint/disabled text
const tTextDisabled = Color(0x42000000); // Disabled text
const tTextOnPrimary = Colors.white; // Text on primary color
const tTextOnSecondary = Colors.white; // Text on secondary color

// Status Colors
const tSuccessColor = Color(0xFF4CAF50); // Success/green
const tErrorColor = Color(0xFFF44336); // Error/red
const tWarningColor = Color(0xFFFFC107); // Warning/amber
const tInfoColor = Color(0xFF2196F3); // Info/blue

// Border Colors
const tBorderColor = Color(0xFFE0E0E0); // Light border
const tDividerColor = Color(0x1F000000); // Divider color

// Onboarding Colors
const tOnBoardingPage1Color = Colors.white;
const tOnBoardingPage2Color = Color(0xFFF5F5F5);
const tOnBoardingPage3Color = Color(0xFFEEEEEE);

// Navigation Colors
const tNavBarColor = tPrimaryColor;
const tNavBarColorButton = Colors.white;
const tBottomNavBarSelected = tPrimaryColor;
const tBottomNavBarUnselected = Color(0xFF9E9E9E);

// Button Colors
const tButtonColor = tPrimaryColor;
const tButtonDisabledColor = Color(0xFFE0E0E0);
const tButtonTextColor = Colors.white;

// Input Field Colors
const tInputBackground = Color(0xFFFAFAFA);
const tInputBorder = Color(0xFFE0E0E0);
const tInputFocusedBorder = tPrimaryColor;
const tInputErrorBorder = tErrorColor;
const tInputLabelColor = Color(0xDE000000);
const tInputHintColor = Color(0x61000000);

// Transparent
const tTransparent = Colors.transparent;

// Social Media Colors
const tGoogleRed = Color(0xFFDB4437);
const tFacebookBlue = Color(0xFF4267B2);
const tTwitterBlue = Color(0xFF1DA1F2);

// Gradients
const tPrimaryGradient = LinearGradient(
  colors: [tPrimaryColor, tPrimaryDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const tSecondaryGradient = LinearGradient(
  colors: [tSecondaryColor, tSecondaryDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Shadows
const tCardShadow = [
  BoxShadow(
    color: Colors.black12,
    blurRadius: 6.0,
    offset: Offset(0, 2),
  ),
];

const tElevationShadow = [
  BoxShadow(
    color: Colors.black26,
    blurRadius: 8.0,
    offset: Offset(0, 4),
  ),
];

// Dark Theme Colors (for future dark mode implementation)
const tDarkPrimaryColor = Color(0xFF212121);
const tDarkSecondaryColor = Color(0xFF424242);
const tDarkBackgroundColor = Color(0xFF121212);
const tDarkSurfaceColor = Color(0xFF1E1E1E);
const tDarkCardColor = Color(0xFF1E1E1E);
const tDarkTextPrimary = Colors.white;
const tDarkTextSecondary = Color(0xB3FFFFFF);
const tDarkTextHint = Color(0x80FFFFFF);
const tDarkTextDisabled = Color(0x4DFFFFFF);
const tDarkDividerColor = Color(0x1FFFFFFF);
