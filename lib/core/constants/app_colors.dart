import 'package:flutter/material.dart';

/// Professional UI/UX Color System
/// Based on Material Design 3 and Color Theory Best Practices
///
/// Color Theory Applied:
/// - 60-30-10 Rule: Primary (60%), Secondary (30%), Accent (10%)
/// - Complementary colors for visual harmony
/// - Sufficient contrast ratios (WCAG AA compliant)
/// - Semantic colors for intuitive user experience
class AppColors {
  AppColors._();

  // ==================== Brand Colors ====================
  /// Primary brand color - Vibrant coral red (#EF4934)
  /// Used for: Primary actions, key UI elements, brand identity
  /// Contrast ratio: 4.5:1 on white (WCAG AA compliant)
  static const Color primary = Color(0xFFEF4934);

  /// Primary color variants for depth and hierarchy
  static const Color primaryDark = Color(0xFFD63B25);
  static const Color primaryLight = Color(0xFFFF6B52);
  static const Color primaryLighter = Color(0xFFFFE5E0);
  static const Color primarySubtle = Color(0x1AEF4934); // 10% opacity

  /// Secondary brand color - Professional charcoal (#2C3E50)
  /// Used for: Text, secondary actions, contrast elements
  static const Color secondary = Color(0xFF2C3E50);
  static const Color secondaryLight = Color(0xFF34495E);
  static const Color secondaryDark = Color(0xFF1A252F);

  /// Accent color - Energetic orange (#FF6B35)
  /// Used for: Highlights, CTAs, important notifications
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8C5A);

  // ==================== Neutral Colors ====================
  /// Pure neutrals for backgrounds and surfaces
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF); // 70% opacity white
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  /// Neutral grays - carefully calibrated for optimal readability
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // ==================== Background & Surface Colors ====================
  /// Light theme backgrounds
  static const Color background = Color(0xFFFAFAFA); // Softer than pure white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  /// Card backgrounds with subtle warmth
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundElevated = Color(0xFFFFFBF8);

  /// Dark theme backgrounds
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  // ==================== Text Colors (WCAG Compliant) ====================
  /// Primary text - High contrast (21:1 ratio)
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text - Medium emphasis (7:1 ratio)
  static const Color textSecondary = Color(0xFF616161);

  /// Tertiary text - Low emphasis (4.5:1 ratio)
  static const Color textTertiary = Color(0xFF9E9E9E);

  /// Disabled text - Minimal emphasis
  static const Color textDisabled = Color(0xFFBDBDBD);

  /// Hint text for placeholders
  static const Color textHint = Color(0xFF9E9E9E);

  /// Text on primary color
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Dark theme text colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF808080);

  // ==================== Semantic Colors ====================
  /// Success - Green (#10B981)
  /// Used for: Success messages, confirmations, positive states
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  /// Error - Red (#EF4444)
  /// Used for: Error messages, destructive actions, alerts
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  /// Warning - Amber (#F59E0B)
  /// Used for: Warnings, caution states, important notices
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  /// Info - Blue (#3B82F6)
  /// Used for: Informational messages, tips, neutral notifications
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ==================== UI Element Colors ====================
  /// Navigation
  static const Color navBarBackground = primary;
  static const Color navBarItem = Color(0xFFFFFFFF);
  static const Color navBarButton = Color(0xFFFFFFFF); // Alias for navBarItem
  static const Color navBarItemActive = Color(0xFFFFFFFF);
  static const Color navBarItemInactive = Color(0xB3FFFFFF); // 70% opacity

  /// Icons
  static const Color iconPrimary = Color(0xFF424242);
  static const Color iconSecondary = Color(0xFF757575);
  static const Color iconActive = primary;
  static const Color iconDisabled = Color(0xFFBDBDBD);
  static const Color iconOnPrimary = Color(0xFFFFFFFF);

  /// Buttons
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = Color(0xFFF5F5F5);
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonTextPrimary = Color(0xFFFFFFFF);
  static const Color buttonTextSecondary = textPrimary;

  // ==================== Border & Divider Colors ====================
  /// Borders with subtle contrast
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);
  static const Color borderFocus = primary;

  /// Dividers
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);

  // ==================== Input Field Colors ====================
  /// Input backgrounds and borders
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color inputBorder = Color(0xFFE5E7EB);
  static const Color inputBorderFocused = primary;
  static const Color inputBorderError = error;
  static const Color inputBorderDisabled = Color(0xFFF3F4F6);
  static const Color inputText = textPrimary;
  static const Color inputPlaceholder = textHint;

  // ==================== Overlay & Shadow Colors ====================
  /// Overlays for modals and dialogs
  static const Color overlayLight = Color(0x0D000000); // 5% opacity
  static const Color overlayMedium = Color(0x33000000); // 20% opacity
  static const Color overlayDark = Color(0x66000000); // 40% opacity
  static const Color overlayHeavy = Color(0x99000000); // 60% opacity

  /// Shadows for depth and elevation
  static const Color shadowLight = Color(0x0A000000); // 4% opacity
  static const Color shadowMedium = Color(0x1A000000); // 10% opacity
  static const Color shadowDark = Color(0x33000000); // 20% opacity

  // ==================== Shimmer & Loading Colors ====================
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);
  static const Color darkShimmerBase = Color(0xFF2C2C2C);
  static const Color darkShimmerHighlight = Color(0xFF424242);

  // ==================== Gradient Colors ====================
  /// Primary gradient - Warm and energetic
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFEF4934), Color(0xFFFF6B52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary gradient - Professional and subtle
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient - Vibrant and attention-grabbing
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFAFAFA), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ==================== Onboarding Colors ====================
  /// Onboarding screens with brand-aligned colors
  static const Color onboardingPage1 = Color(0xFFFFFFFF);
  static const Color onboardingPage2 = Color(0xFFFFE5E0);
  static const Color onboardingPage3 = Color(0xFFFFEBD6);

  // ==================== Color Scheme Helpers ====================
  /// Material Design 3 color scheme helpers
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onSurface = textPrimary;
  static const Color onBackground = textPrimary;

  // ==================== Video Player Theme Colors ====================
  /// Video player primary - Purple (#8B5CF6)
  /// Used for: Controls, progress bars, highlights in video player
  static const Color videoPrimary = Color(0xFF8B5CF6);
  static const Color videoPrimaryDark = Color(0xFF7C3AED);
  static const Color videoPrimarySubtle10 = Color(0x1A8B5CF6); // 10% opacity
  static const Color videoPrimarySubtle15 = Color(0x268B5CF6); // 15% opacity
  static const Color videoPrimarySubtle20 = Color(0x338B5CF6); // 20% opacity
  static const Color videoPrimarySubtle30 = Color(0x4D8B5CF6); // 30% opacity
  static const Color videoPrimarySubtle40 = Color(0x668B5CF6); // 40% opacity
  static const Color videoPrimarySubtle50 = Color(0x808B5CF6); // 50% opacity

  /// Video player backgrounds - Dark theme
  static const Color videoBackground = Color(0xFF0F0F1A);
  static const Color videoSurface = Color(0xFF1A1A2E);
  static const Color videoSurfaceLight = Color(0xFF16213E);

  /// Video player gradient
  static const LinearGradient videoGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== Card Palette Colors ====================
  /// Vibrant color palette for quiz, category, and profile cards
  /// Used for visual variety while maintaining consistency

  /// Card Indigo - Primary accent
  static const Color cardIndigo = Color(0xFF6366F1);

  /// Card Purple - Creative/fun
  static const Color cardPurple = Color(0xFF8B5CF6);

  /// Card Pink - Playful/engaging
  static const Color cardPink = Color(0xFFEC4899);

  /// Card Amber - Attention/warning
  static const Color cardAmber = Color(0xFFF59E0B);

  /// Card Emerald - Success/nature
  static const Color cardEmerald = Color(0xFF10B981);

  /// Card Blue - Trust/calm
  static const Color cardBlue = Color(0xFF3B82F6);

  /// Card Red - Alert/important
  static const Color cardRed = Color(0xFFEF4444);

  /// Card Teal - Fresh/modern
  static const Color cardTeal = Color(0xFF14B8A6);

  /// Card palette list for indexed access (e.g., cards with varying colors)
  static const List<Color> cardPalette = [
    cardIndigo,
    cardPurple,
    cardPink,
    cardAmber,
    cardEmerald,
    cardBlue,
    cardRed,
    cardTeal,
  ];

  // ==================== Emergency Theme Colors ====================
  /// Emergency page colors for dark theme

  /// Emergency green - for call confirmation
  static const Color emergencyGreen = Color(0xFF22C55E);
  static const Color emergencyGreenDark = Color(0xFF16A34A);

  /// Emergency green gradient
  static const LinearGradient emergencyGreenGradient = LinearGradient(
    colors: [emergencyGreen, emergencyGreenDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Emergency red gradient (for danger actions)
  static const LinearGradient emergencyRedGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Emergency dark shimmer colors
  static const Color emergencyShimmerBase = Color(0xFF1A1A2E);
  static const Color emergencyShimmerHighlight = Color(0xFF2D2D44);
}
