# UI/UX Design System Guidelines

## Overview
This document outlines the professional UI/UX design system implemented in GuardianCare, following Material Design 3 principles and industry best practices.

---

## 🎨 Color System

### Color Theory Applied
- **60-30-10 Rule**: Primary (60%), Secondary (30%), Accent (10%)
- **WCAG AA Compliance**: All text colors meet 4.5:1 contrast ratio minimum
- **Semantic Colors**: Intuitive color meanings (green=success, red=error, etc.)

### Primary Colors
```dart
AppColors.primary        // #EF4934 - Vibrant coral red (brand identity)
AppColors.primaryDark    // #D63B25 - Darker variant for depth
AppColors.primaryLight   // #FF6B52 - Lighter variant for highlights
AppColors.primaryLighter // #FFE5E0 - Subtle backgrounds
```

### Semantic Colors
```dart
AppColors.success  // #10B981 - Green (positive actions)
AppColors.error    // #EF4444 - Red (errors, warnings)
AppColors.warning  // #F59E0B - Amber (caution)
AppColors.info     // #3B82F6 - Blue (information)
```

### Usage Guidelines
- Use `primary` for CTAs and key actions
- Use `secondary` for text and supporting elements
- Use `accent` sparingly for highlights
- Always check contrast ratios for accessibility

---

## 📏 Spacing System (8pt Grid)

### Base Unit
All spacing is based on 8pt increments for visual consistency:

```dart
AppDimensions.spaceXXS  // 2px  (0.25x base)
AppDimensions.spaceXS   // 4px  (0.5x base)
AppDimensions.spaceS    // 8px  (1x base)
AppDimensions.spaceM    // 16px (2x base)
AppDimensions.spaceL    // 24px (3x base)
AppDimensions.spaceXL   // 32px (4x base)
AppDimensions.spaceXXL  // 48px (6x base)
```

### Padding Guidelines
- **Screen padding**: 20px horizontal, 16px vertical
- **Card padding**: 16px (standard), 20px (large)
- **Button padding**: 24px horizontal, 14px vertical
- **List items**: 16px horizontal, 12px vertical

### When to Use Each Size
- **XXS-XS**: Icon spacing, tight layouts
- **S**: Component internal spacing
- **M**: Default spacing between elements
- **L**: Section spacing
- **XL-XXL**: Major section breaks

---

## 🔤 Typography System

### Font Family
**Poppins** - Modern, readable, professional sans-serif

### Type Scale (Modular Scale 1.25)
```dart
// Display Styles (Hero Text)
AppTextStyles.displayLarge  // 57px - Landing pages
AppTextStyles.displayMedium // 45px - Hero sections
AppTextStyles.displaySmall  // 36px - Large headers

// Headings
AppTextStyles.h1  // 32px - Page titles
AppTextStyles.h2  // 28px - Section titles
AppTextStyles.h3  // 24px - Subsections
AppTextStyles.h4  // 20px - Card titles
AppTextStyles.h5  // 18px - Small headers
AppTextStyles.h6  // 16px - Smallest headers

// Body Text
AppTextStyles.bodyLarge  // 16px - Emphasized content
AppTextStyles.bodyMedium // 14px - Default body text
AppTextStyles.bodySmall  // 12px - Compact text
```

### Typography Best Practices
- **Line Height**: 1.4-1.6 for optimal readability
- **Letter Spacing**: Adjusted per size for clarity
- **Max Line Length**: 50-75 characters for body text
- **Hierarchy**: Use size, weight, and color to create clear hierarchy

---

## 🔘 Border Radius System

### Radius Scale
```dart
AppDimensions.radiusXS  // 4px  - Subtle rounding
AppDimensions.radiusS   // 8px  - Buttons, chips
AppDimensions.radiusM   // 12px - Cards, inputs (most common)
AppDimensions.radiusL   // 16px - Modals, sheets
AppDimensions.radiusXL  // 24px - Hero elements
AppDimensions.radiusXXL // 32px - Special elements
```

### Usage Guidelines
- **Buttons**: radiusS or radiusM
- **Cards**: radiusM or radiusL
- **Inputs**: radiusM
- **Modals**: radiusL
- **Avatars**: radiusCircular

---

## 🎯 Touch Targets & Accessibility

### Minimum Sizes (WCAG 2.1 Level AAA)
```dart
AppDimensions.minTouchTarget        // 48x48dp minimum
AppDimensions.recommendedTouchTarget // 56x56dp recommended
AppDimensions.minTouchTargetSpacing  // 8px between targets
```

### Button Sizes
```dart
AppDimensions.buttonHeightS  // 40px - Compact spaces
AppDimensions.buttonHeight   // 48px - Default (meets touch target)
AppDimensions.buttonHeightL  // 56px - Primary actions
```

### Accessibility Checklist
- ✅ All interactive elements ≥ 48x48dp
- ✅ Text contrast ratio ≥ 4.5:1 (WCAG AA)
- ✅ Focus indicators visible
- ✅ Touch targets spaced ≥ 8px apart
- ✅ Semantic colors for status

---

## 🎭 Elevation System (Material Design 3)

### Elevation Levels
```dart
AppDimensions.elevation0  // 0dp  - Flat surfaces
AppDimensions.elevation1  // 1dp  - Subtle lift
AppDimensions.elevation2  // 2dp  - Cards at rest
AppDimensions.elevation3  // 4dp  - Floating elements
AppDimensions.elevation4  // 8dp  - Modals, dialogs
AppDimensions.elevation5  // 16dp - Tooltips, menus
```

### Usage Guidelines
- **Cards**: elevation2 (rest), elevation3 (hover)
- **Buttons**: elevation2
- **Modals**: elevation4
- **Menus**: elevation5
- **App Bar**: elevation0 (flat design)

---

## 🎨 Component Guidelines

### Buttons
```dart
// Primary Action
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    padding: AppDimensions.buttonPadding,
    minimumSize: Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
  ),
)

// Secondary Action
OutlinedButton(...)

// Tertiary Action
TextButton(...)
```

### Input Fields
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: AppColors.inputBackground,
    border: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusM,
      borderSide: BorderSide(
        color: AppColors.inputBorder,
        width: AppDimensions.borderThin,
      ),
    ),
    contentPadding: AppDimensions.inputPadding,
  ),
)
```

### Cards
```dart
Card(
  elevation: AppDimensions.cardElevation,
  shape: RoundedRectangleBorder(
    borderRadius: AppDimensions.borderRadiusL,
  ),
  child: Padding(
    padding: AppDimensions.cardPaddingAll,
    child: ...,
  ),
)
```

---

## 📱 Responsive Design

### Breakpoints
```dart
AppDimensions.breakpointMobile   // 600px
AppDimensions.breakpointTablet   // 900px
AppDimensions.breakpointDesktop  // 1200px
```

### Max Content Width
```dart
AppDimensions.maxContentWidthNarrow // 600px  - Forms, reading
AppDimensions.maxContentWidth       // 1200px - General content
AppDimensions.maxContentWidthWide   // 1440px - Wide layouts
```

---

## ⚡ Animation Guidelines

### Duration Standards
```dart
AppDimensions.durationQuick    // 150ms - Micro-interactions
AppDimensions.durationStandard // 300ms - Most transitions
AppDimensions.durationSlow     // 500ms - Complex animations
```

### Animation Principles
- **Quick**: Hover states, ripples, toggles
- **Standard**: Page transitions, dialogs
- **Slow**: Complex multi-step animations
- Use easing curves for natural motion

---

## 🎯 Best Practices Summary

### DO ✅
- Use the 8pt grid system consistently
- Maintain WCAG AA contrast ratios
- Provide 48x48dp touch targets
- Use semantic colors appropriately
- Follow the type scale hierarchy
- Apply consistent border radius
- Use elevation to show hierarchy
- Test on multiple screen sizes

### DON'T ❌
- Use arbitrary spacing values
- Mix different spacing systems
- Create touch targets < 48x48dp
- Use low-contrast color combinations
- Override theme styles unnecessarily
- Use too many font sizes
- Apply inconsistent border radius
- Ignore accessibility guidelines

---

## 📚 Resources

### Material Design 3
- [Material Design Guidelines](https://m3.material.io/)
- [Color System](https://m3.material.io/styles/color/overview)
- [Typography](https://m3.material.io/styles/typography/overview)

### Accessibility
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Contrast Checker](https://webaim.org/resources/contrastchecker/)

### Design Tools
- [8pt Grid System](https://spec.fm/specifics/8-pt-grid)
- [Modular Scale Calculator](https://www.modularscale.com/)

---

## 🔄 Migration from Old Constants

### Deprecated Constants (Remove These)
```dart
// OLD - Don't use
tPrimaryColor
tSecondaryColor
tTextPrimary
tCardBgColor

// NEW - Use these instead
AppColors.primary
AppColors.secondary
AppColors.textPrimary
AppColors.cardBackground
```

All deprecated constants have been removed. Use the new `AppColors`, `AppDimensions`, and `AppTextStyles` classes.

---

**Last Updated**: December 2024
**Version**: 2.0.0
**Status**: ✅ Production Ready
