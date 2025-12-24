# Hardcoded Values Migration Guide

## Overview
This document provides a comprehensive guide for replacing all hardcoded values with centralized constants from the design system.

---

## 🎯 Common Hardcoded Values to Replace

### 1. **Colors**

#### Hardcoded Colors → AppColors
```dart
// ❌ DON'T
Colors.red → AppColors.error
Colors.green → AppColors.success
Colors.blue → AppColors.info
Colors.orange → AppColors.warning
Colors.grey[100] → AppColors.gray100
Colors.grey[600] → AppColors.gray600
Colors.white → AppColors.white
Colors.black → AppColors.black

// ✅ DO
backgroundColor: AppColors.error
color: AppColors.success
```

#### Color Opacity
```dart
// ❌ DON'T
Colors.grey.withOpacity(0.2)
Colors.black.withOpacity(0.5)

// ✅ DO
AppColors.shadowMedium
AppColors.overlayMedium
AppColors.primarySubtle
```

---

### 2. **Spacing & Padding**

#### EdgeInsets → AppDimensions
```dart
// ❌ DON'T
EdgeInsets.all(8) → AppDimensions.paddingAllS
EdgeInsets.all(12) → AppDimensions.paddingAllM (use 16)
EdgeInsets.all(16) → AppDimensions.paddingAllM
EdgeInsets.all(20) → AppDimensions.paddingAllL (use 24)
EdgeInsets.all(24) → AppDimensions.paddingAllL

EdgeInsets.symmetric(horizontal: 16) → AppDimensions.paddingHorizontalM
EdgeInsets.symmetric(vertical: 8) → AppDimensions.paddingVerticalS
EdgeInsets.symmetric(horizontal: 16, vertical: 8) → AppDimensions.listItemPadding

EdgeInsets.only(bottom: 12) → EdgeInsets.only(bottom: AppDimensions.spaceM)
EdgeInsets.only(top: 16) → EdgeInsets.only(top: AppDimensions.spaceM)

// ✅ DO
padding: AppDimensions.paddingAllM
margin: EdgeInsets.symmetric(
  horizontal: AppDimensions.spaceM,
  vertical: AppDimensions.spaceS,
)
```

#### SizedBox → AppDimensions
```dart
// ❌ DON'T
SizedBox(height: 4) → SizedBox(height: AppDimensions.spaceXS)
SizedBox(height: 8) → SizedBox(height: AppDimensions.spaceS)
SizedBox(height: 12) → SizedBox(height: AppDimensions.spaceM) (use 16)
SizedBox(height: 16) → SizedBox(height: AppDimensions.spaceM)
SizedBox(height: 24) → SizedBox(height: AppDimensions.spaceL)
SizedBox(height: 32) → SizedBox(height: AppDimensions.spaceXL)

SizedBox(width: 8) → SizedBox(width: AppDimensions.spaceS)
SizedBox(width: 16) → SizedBox(width: AppDimensions.spaceM)

// ✅ DO
SizedBox(height: AppDimensions.spaceM)
SizedBox(width: AppDimensions.spaceS)
```

---

### 3. **Border Radius**

#### BorderRadius.circular → AppDimensions
```dart
// ❌ DON'T
BorderRadius.circular(4) → AppDimensions.borderRadiusXS
BorderRadius.circular(8) → AppDimensions.borderRadiusS
BorderRadius.circular(12) → AppDimensions.borderRadiusM
BorderRadius.circular(16) → AppDimensions.borderRadiusL
BorderRadius.circular(20) → AppDimensions.borderRadiusXL
BorderRadius.circular(24) → AppDimensions.borderRadiusXL
BorderRadius.circular(100) → AppDimensions.borderRadiusCircular

// ✅ DO
borderRadius: AppDimensions.borderRadiusM
shape: RoundedRectangleBorder(
  borderRadius: AppDimensions.borderRadiusL,
)
```

---

### 4. **Typography**

#### TextStyle → AppTextStyles
```dart
// ❌ DON'T
TextStyle(fontSize: 32, fontWeight: FontWeight.bold) → AppTextStyles.h1
TextStyle(fontSize: 28, fontWeight: FontWeight.bold) → AppTextStyles.h2
TextStyle(fontSize: 24, fontWeight: FontWeight.w600) → AppTextStyles.h3
TextStyle(fontSize: 20, fontWeight: FontWeight.w600) → AppTextStyles.h4
TextStyle(fontSize: 18, fontWeight: FontWeight.w600) → AppTextStyles.h5
TextStyle(fontSize: 16, fontWeight: FontWeight.w600) → AppTextStyles.h6

TextStyle(fontSize: 16) → AppTextStyles.bodyLarge
TextStyle(fontSize: 14) → AppTextStyles.bodyMedium
TextStyle(fontSize: 12) → AppTextStyles.bodySmall

TextStyle(fontSize: 12, color: Colors.grey) → AppTextStyles.caption

// ✅ DO
style: AppTextStyles.h4
style: AppTextStyles.bodyMedium
style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)
```

---

### 5. **Elevation & Shadows**

#### Elevation → AppDimensions
```dart
// ❌ DON'T
elevation: 1 → AppDimensions.elevation1
elevation: 2 → AppDimensions.elevation2
elevation: 4 → AppDimensions.elevation3
elevation: 8 → AppDimensions.elevation4
elevation: 16 → AppDimensions.elevation5

// ✅ DO
elevation: AppDimensions.cardElevation
elevation: AppDimensions.modalElevation
```

#### BoxShadow → AppColors
```dart
// ❌ DON'T
BoxShadow(
  color: Colors.grey.withOpacity(0.2),
  spreadRadius: 1,
  blurRadius: 4,
)

// ✅ DO
BoxShadow(
  color: AppColors.shadowMedium,
  spreadRadius: 1,
  blurRadius: 4,
  offset: Offset(0, 2),
)
```

---

### 6. **Icon Sizes**

#### Icon Size → AppDimensions
```dart
// ❌ DON'T
Icon(Icons.add, size: 16) → AppDimensions.iconXS
Icon(Icons.add, size: 20) → AppDimensions.iconS
Icon(Icons.add, size: 24) → AppDimensions.iconM
Icon(Icons.add, size: 32) → AppDimensions.iconL
Icon(Icons.add, size: 48) → AppDimensions.iconXL

// ✅ DO
Icon(
  Icons.add,
  size: AppDimensions.iconM,
  color: AppColors.iconPrimary,
)
```

---

### 7. **Button Styling**

#### Button Padding → AppDimensions
```dart
// ❌ DON'T
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
)

// ✅ DO
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: AppDimensions.buttonPadding,
    minimumSize: Size(
      AppDimensions.buttonMinWidth,
      AppDimensions.buttonHeight,
    ),
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusM,
    ),
  ),
)
```

---

### 8. **Input Fields**

#### TextField Decoration → AppDimensions + AppColors
```dart
// ❌ DON'T
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    contentPadding: EdgeInsets.all(16),
  ),
)

// ✅ DO
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
    focusedBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadiusM,
      borderSide: BorderSide(
        color: AppColors.inputBorderFocused,
        width: AppDimensions.borderThick,
      ),
    ),
    contentPadding: AppDimensions.inputPadding,
    hintStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.inputPlaceholder,
    ),
  ),
  style: AppTextStyles.bodyMedium,
)
```

---

### 9. **Cards**

#### Card Styling → AppDimensions + AppColors
```dart
// ❌ DON'T
Card(
  margin: EdgeInsets.all(16),
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
)

// ✅ DO
Card(
  margin: AppDimensions.paddingAllM,
  elevation: AppDimensions.cardElevation,
  color: AppColors.cardBackground,
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

### 10. **Dialogs**

#### Dialog Styling → AppDimensions + AppColors
```dart
// ❌ DON'T
AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: Text('Title'),
  content: Text('Content'),
)

// ✅ DO
AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: AppDimensions.borderRadiusL,
  ),
  backgroundColor: AppColors.surface,
  elevation: AppDimensions.dialogElevation,
  title: Text('Title', style: AppTextStyles.h4),
  content: Text('Content', style: AppTextStyles.bodyMedium),
  contentPadding: AppDimensions.dialogPadding,
)
```

---

## 🔍 Finding Hardcoded Values

### Search Patterns
Use these regex patterns to find hardcoded values:

```regex
# Colors
Colors\.(red|green|blue|orange|grey|white|black)
Color\(0x[0-9A-F]{8}\)

# Padding/Margins
EdgeInsets\.(all|symmetric|only)\(\d+
const EdgeInsets\.

# Border Radius
BorderRadius\.circular\(\d+

# Font Sizes
fontSize:\s*\d+

# Elevation
elevation:\s*\d+

# Icon Sizes
size:\s*\d+

# Width/Height
width:\s*\d+
height:\s*\d+
```

---

## 📝 Migration Checklist

### Per File
- [ ] Replace all hardcoded colors with AppColors
- [ ] Replace all EdgeInsets with AppDimensions
- [ ] Replace all BorderRadius with AppDimensions
- [ ] Replace all TextStyle with AppTextStyles
- [ ] Replace all elevation values with AppDimensions
- [ ] Replace all icon sizes with AppDimensions
- [ ] Add missing imports (app_colors, app_dimensions, app_text_styles)
- [ ] Test the file for visual consistency
- [ ] Run `flutter analyze` to check for errors

### Project-Wide
- [ ] Scan all files in `lib/features/`
- [ ] Update all presentation layer files
- [ ] Update all widget files
- [ ] Update all page files
- [ ] Remove any remaining hardcoded values
- [ ] Run full app test
- [ ] Verify UI consistency across all screens

---

## 🚀 Automated Migration Script

### Find All Hardcoded Values
```bash
# Find hardcoded colors
grep -r "Colors\." lib/features/ --include="*.dart"

# Find hardcoded EdgeInsets
grep -r "EdgeInsets\.(all|symmetric|only)(" lib/features/ --include="*.dart"

# Find hardcoded BorderRadius
grep -r "BorderRadius\.circular(" lib/features/ --include="*.dart"

# Find hardcoded font sizes
grep -r "fontSize:" lib/features/ --include="*.dart"
```

---

## 📊 Priority Files to Migrate

### High Priority (User-Facing)
1. ✅ `lib/features/forum/presentation/pages/forum_page_example.dart`
2. `lib/features/home/presentation/widgets/home_carousel_widget.dart`
3. `lib/features/authentication/presentation/pages/email_verification_page.dart`
4. `lib/features/consent/presentation/pages/enhanced_consent_form_page.dart`
5. `lib/features/emergency/presentation/pages/emergency_contact_page.dart`

### Medium Priority (Supporting UI)
6. `lib/features/forum/presentation/widgets/comment_item.dart`
7. `lib/features/forum/presentation/widgets/comment_input_widget.dart`
8. `lib/features/forum/presentation/widgets/user_details_widget.dart`
9. `lib/features/consent/presentation/widgets/forgot_parental_key_dialog.dart`

### Low Priority (Less Visible)
10. Other widget files
11. Helper widgets
12. Internal components

---

## ✅ Benefits After Migration

### Consistency
- Uniform spacing across all screens
- Consistent color usage
- Standardized typography

### Maintainability
- Single source of truth for design values
- Easy global design updates
- Reduced code duplication

### Accessibility
- WCAG compliant colors by default
- Proper touch target sizes
- Consistent contrast ratios

### Performance
- Compile-time constants (no runtime calculations)
- Reduced widget rebuilds
- Smaller bundle size

---

## 📚 Quick Reference

### Most Common Replacements
```dart
// Spacing
8  → AppDimensions.spaceS
16 → AppDimensions.spaceM
24 → AppDimensions.spaceL

// Border Radius
8  → AppDimensions.radiusS
12 → AppDimensions.radiusM
16 → AppDimensions.radiusL

// Colors
Colors.red → AppColors.error
Colors.green → AppColors.success
Colors.grey[600] → AppColors.gray600

// Typography
fontSize: 16 → AppTextStyles.bodyLarge
fontSize: 14 → AppTextStyles.bodyMedium
fontSize: 12 → AppTextStyles.caption
```

---

**Last Updated**: December 2024
**Status**: 🔄 In Progress
**Completion**: ~30% (forum_page_example.dart completed)
