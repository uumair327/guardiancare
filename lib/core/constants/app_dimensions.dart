import 'package:flutter/material.dart';

/// Professional UI/UX Spacing & Dimension System
/// Based on 8pt Grid System and Material Design Guidelines
/// 
/// Design Principles:
/// - 8pt base unit for consistent rhythm
/// - Golden ratio (1.618) for harmonious proportions
/// - Touch target minimum: 48x48dp (Material Design)
/// - Optimal line length: 50-75 characters
/// - Comfortable reading distance: 16-24px line height
class AppDimensions {
  AppDimensions._();

  // ==================== Spacing System (8pt Grid) ====================
  /// Base unit for all spacing calculations
  static const double baseUnit = 8.0;
  
  /// Extra extra small spacing - 2.0 (0.25x base)
  static const double spaceXXS = 2.0;
  
  /// Extra small spacing - 4.0 (0.5x base)
  static const double spaceXS = 4.0;
  
  /// Small spacing - 8.0 (1x base)
  static const double spaceS = 8.0;
  
  /// Medium spacing - 16.0 (2x base)
  static const double spaceM = 16.0;
  
  /// Large spacing - 24.0 (3x base)
  static const double spaceL = 24.0;
  
  /// Extra large spacing - 32.0 (4x base)
  static const double spaceXL = 32.0;
  
  /// Extra extra large spacing - 48.0 (6x base)
  static const double spaceXXL = 48.0;
  
  /// Extra extra extra large spacing - 64.0 (8x base)
  static const double spaceXXXL = 64.0;

  // ==================== Padding System ====================
  /// Screen padding - Optimal for content readability
  static const double screenPaddingH = 20.0;
  static const double screenPaddingV = 16.0;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingH,
    vertical: screenPaddingV,
  );
  
  /// Card padding - Comfortable content spacing
  static const double cardPadding = 16.0;
  static const double cardPaddingLarge = 20.0;
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  
  /// Button padding - Touch-friendly targets
  static const double buttonPaddingH = 24.0;
  static const double buttonPaddingV = 14.0;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: buttonPaddingH,
    vertical: buttonPaddingV,
  );
  
  /// Input field padding - Optimal for text entry
  static const double inputPaddingH = 16.0;
  static const double inputPaddingV = 16.0;
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: inputPaddingH,
    vertical: inputPaddingV,
  );
  
  /// List item padding
  static const double listItemPaddingH = 16.0;
  static const double listItemPaddingV = 12.0;
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: listItemPaddingH,
    vertical: listItemPaddingV,
  );
  
  /// EdgeInsets presets for quick use
  static const paddingAllXXS = EdgeInsets.all(spaceXXS);
  static const paddingAllXS = EdgeInsets.all(spaceXS);
  static const paddingAllS = EdgeInsets.all(spaceS);
  static const paddingAllM = EdgeInsets.all(spaceM);
  static const paddingAllL = EdgeInsets.all(spaceL);
  static const paddingAllXL = EdgeInsets.all(spaceXL);
  static const paddingAllXXL = EdgeInsets.all(spaceXXL);
  
  /// Horizontal padding presets
  static const paddingHorizontalS = EdgeInsets.symmetric(horizontal: spaceS);
  static const paddingHorizontalM = EdgeInsets.symmetric(horizontal: spaceM);
  static const paddingHorizontalL = EdgeInsets.symmetric(horizontal: spaceL);
  
  /// Vertical padding presets
  static const paddingVerticalS = EdgeInsets.symmetric(vertical: spaceS);
  static const paddingVerticalM = EdgeInsets.symmetric(vertical: spaceM);
  static const paddingVerticalL = EdgeInsets.symmetric(vertical: spaceL);

  // ==================== Border Radius System ====================
  /// Extra small radius - Subtle rounding
  static const double radiusXS = 4.0;
  
  /// Small radius - Buttons, chips
  static const double radiusS = 8.0;
  
  /// Medium radius - Cards, inputs (most common)
  static const double radiusM = 12.0;
  
  /// Large radius - Modals, sheets
  static const double radiusL = 16.0;
  
  /// Extra large radius - Hero elements
  static const double radiusXL = 24.0;
  
  /// Extra extra large radius - Special elements
  static const double radiusXXL = 32.0;
  
  /// Circular radius - Avatars, FABs
  static const double radiusCircular = 999.0;
  
  /// BorderRadius presets for quick use
  static final borderRadiusXS = BorderRadius.circular(radiusXS);
  static final borderRadiusS = BorderRadius.circular(radiusS);
  static final borderRadiusM = BorderRadius.circular(radiusM);
  static final borderRadiusL = BorderRadius.circular(radiusL);
  static final borderRadiusXL = BorderRadius.circular(radiusXL);
  static final borderRadiusXXL = BorderRadius.circular(radiusXXL);
  static final borderRadiusCircular = BorderRadius.circular(radiusCircular);
  
  /// Top-only radius presets
  static final borderRadiusTopM = BorderRadius.vertical(top: Radius.circular(radiusM));
  static final borderRadiusTopL = BorderRadius.vertical(top: Radius.circular(radiusL));
  
  /// Bottom-only radius presets
  static final borderRadiusBottomM = BorderRadius.vertical(bottom: Radius.circular(radiusM));
  static final borderRadiusBottomL = BorderRadius.vertical(bottom: Radius.circular(radiusL));

  // ==================== Icon Sizes ====================
  
  /// Extra small icon - 16.0
  static const double iconXS = 16.0;
  
  /// Small icon - 20.0
  static const double iconS = 20.0;
  
  /// Medium icon - 24.0
  static const double iconM = 24.0;
  
  /// Large icon - 32.0
  static const double iconL = 32.0;
  
  /// Extra large icon - 48.0
  static const double iconXL = 48.0;
  
  /// Extra extra large icon - 64.0
  static const double iconXXL = 64.0;

  // ==================== Button Sizes (Touch-Optimized) ====================
  /// Small button - Compact spaces
  static const double buttonHeightS = 40.0;
  static const double buttonMinWidthS = 88.0;
  
  /// Medium button - Default size (48dp minimum touch target)
  static const double buttonHeight = 48.0;
  static const double buttonMinWidth = 120.0;
  
  /// Large button - Primary actions
  static const double buttonHeightL = 56.0;
  static const double buttonMinWidthL = 160.0;
  
  /// Icon button size (48x48 touch target)
  static const double iconButtonSize = 48.0;

  // ==================== App Bar ====================
  
  /// App bar height
  static const double appBarHeight = 56.0;
  
  /// App bar elevation
  static const double appBarElevation = 0.0;

  // ==================== Elevation System (Material Design 3) ====================
  /// Level 0 - No elevation
  static const double elevation0 = 0.0;
  
  /// Level 1 - Subtle lift (cards at rest)
  static const double elevation1 = 1.0;
  
  /// Level 2 - Low elevation (raised cards)
  static const double elevation2 = 2.0;
  
  /// Level 3 - Medium elevation (floating elements)
  static const double elevation3 = 4.0;
  
  /// Level 4 - High elevation (modals, dialogs)
  static const double elevation4 = 8.0;
  
  /// Level 5 - Highest elevation (tooltips, menus)
  static const double elevation5 = 16.0;
  
  /// Semantic elevation aliases
  static const double elevationS = elevation1;
  static const double elevationM = elevation3;
  static const double elevationL = elevation4;
  
  static const double cardElevation = elevation2;
  static const double cardElevationLow = elevation1;
  static const double cardElevationHigh = elevation3;
  static const double cardElevationHover = elevation3;
  static const double modalElevation = elevation4;
  static const double menuElevation = elevation5;

  // ==================== Divider ====================
  
  /// Divider thickness
  static const double dividerThickness = 1.0;
  
  /// Divider indent
  static const double dividerIndent = 16.0;

  // ==================== Border Width System ====================
  /// Hairline border - Subtle separation
  static const double borderHairline = 0.5;
  
  /// Thin border - Default borders
  static const double borderThin = 1.0;
  
  /// Medium border - Emphasized borders
  static const double borderMedium = 1.5;
  
  /// Thick border - Focus states, active elements
  static const double borderThick = 2.0;
  
  /// Extra thick border - Strong emphasis
  static const double borderExtraThick = 3.0;

  // ==================== Avatar Sizes ====================
  
  /// Small avatar - 32.0
  static const double avatarS = 32.0;
  
  /// Medium avatar - 48.0
  static const double avatarM = 48.0;
  
  /// Large avatar - 64.0
  static const double avatarL = 64.0;
  
  /// Extra large avatar - 96.0
  static const double avatarXL = 96.0;

  // ==================== Logo Sizes ====================
  
  /// Small logo - 80.0
  static const double logoS = 80.0;
  
  /// Medium logo - 120.0
  static const double logoM = 120.0;
  
  /// Large logo - 160.0
  static const double logoL = 160.0;

  // ==================== Input Field Dimensions ====================
  /// Small input height
  static const double inputHeightS = 40.0;
  
  /// Medium input height (default, 48dp touch target)
  static const double inputHeight = 48.0;
  
  /// Large input height
  static const double inputHeightL = 56.0;
  
  /// Input field line constraints
  static const int inputMinLines = 1;
  static const int inputMaxLines = 1;
  
  /// Text area line constraints
  static const int textAreaMinLines = 4;
  static const int textAreaMaxLines = 8;
  
  /// Search bar height
  static const double searchBarHeight = 48.0;

  // ==================== List Item ====================
  
  /// List item height
  static const double listItemHeight = 72.0;
  
  /// List item height small
  static const double listItemHeightS = 56.0;
  
  /// List item height large
  static const double listItemHeightL = 88.0;

  // ==================== Bottom Navigation ====================
  
  /// Bottom navigation height
  static const double bottomNavHeight = 60.0;
  
  /// Bottom navigation icon size
  static const double bottomNavIconSize = 28.0;

  // ==================== Carousel & Media ====================
  /// Carousel aspect ratios
  static const double carouselAspectRatio = 16 / 9;
  static const double carouselAspectRatioSquare = 1.0;
  static const double carouselAspectRatioPortrait = 3 / 4;
  
  /// Carousel viewport settings
  static const double carouselViewportFraction = 0.9;
  static const double carouselItemSpacing = 16.0;

  // ==================== Dialog & Modal Dimensions ====================
  /// Dialog sizing
  static const double dialogMinWidth = 280.0;
  static const double dialogMaxWidth = 560.0;
  static const double dialogMaxHeight = 600.0;
  
  /// Dialog styling
  static const double dialogRadius = radiusL;
  static const double dialogElevation = elevation4;
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);
  
  /// Bottom sheet
  static const double bottomSheetMaxHeight = 0.9; // 90% of screen
  static const double bottomSheetRadius = radiusXL;

  // ==================== Circular Button (Home Page) ====================
  
  /// Circular button size
  static const double circularButtonSize = 70.0;
  
  /// Circular button size (alias for consistency)
  static const double buttonCircularSize = 70.0;
  
  /// Circular button icon size
  static const double circularButtonIconSize = 32.0;

  // ==================== Shimmer ====================
  
  /// Shimmer height
  static const double shimmerHeight = 200.0;
  
  /// Shimmer border radius
  static const double shimmerRadius = 12.0;

  // ==================== Responsive Breakpoints ====================
  /// Mobile breakpoint
  static const double breakpointMobile = 600.0;
  
  /// Tablet breakpoint
  static const double breakpointTablet = 900.0;
  
  /// Desktop breakpoint
  static const double breakpointDesktop = 1200.0;
  
  /// Max content width for optimal readability
  static const double maxContentWidth = 1200.0;
  static const double maxContentWidthNarrow = 600.0;
  static const double maxContentWidthWide = 1440.0;
  
  // ==================== Animation Durations ====================
  /// Quick animations (micro-interactions)
  static const Duration durationQuick = Duration(milliseconds: 150);
  
  /// Standard animations (most UI transitions)
  static const Duration durationStandard = Duration(milliseconds: 300);
  
  /// Slow animations (complex transitions)
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  // ==================== Accessibility ====================
  /// Minimum touch target size (WCAG 2.1 Level AAA)
  static const double minTouchTarget = 48.0;
  
  /// Recommended touch target size
  static const double recommendedTouchTarget = 56.0;
  
  /// Minimum spacing between touch targets
  static const double minTouchTargetSpacing = 8.0;
}
