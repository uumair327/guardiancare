# GuardianCare Design System

## 🎨 Quick Start

### Single Import
```dart
import 'package:guardiancare/core/constants/constants.dart';
```

This gives you access to:
- **AppColors** - 80+ semantic colors
- **AppDimensions** - 100+ spacing & sizing values
- **AppTextStyles** - 25+ typography styles
- **AppTheme** - Complete Material Design 3 theme

---

## 📚 Documentation

### Essential Guides
1. **[QUICK_START.md](QUICK_START.md)** - 30-second reference guide
2. **[UI_UX_GUIDELINES.md](UI_UX_GUIDELINES.md)** - Complete design system
3. **[HARDCODED_VALUES_MIGRATION.md](HARDCODED_VALUES_MIGRATION.md)** - Migration guide
4. **[CONSTANTS_VERIFICATION.md](CONSTANTS_VERIFICATION.md)** - Verification report

---

## 🚀 Common Usage

### Colors
```dart
color: AppColors.primary
backgroundColor: AppColors.surface
color: AppColors.textPrimary
```

### Spacing
```dart
padding: AppDimensions.paddingAllM
SizedBox(height: AppDimensions.spaceL)
margin: EdgeInsets.all(AppDimensions.spaceM)
```

### Typography
```dart
style: AppTextStyles.h4
style: AppTextStyles.bodyMedium
style: AppTextStyles.caption
```

### Border Radius
```dart
borderRadius: AppDimensions.borderRadiusM
shape: RoundedRectangleBorder(
  borderRadius: AppDimensions.borderRadiusL,
)
```

---

## ✅ What's Included

### Colors (80+)
- Primary, secondary, accent colors
- Semantic colors (success, error, warning, info)
- Text colors (primary, secondary, tertiary)
- Background & surface colors
- Border & divider colors
- Input field colors
- Icon & button colors

### Dimensions (100+)
- 8pt grid spacing system
- Padding & margin presets
- Border radius (XS to XXL)
- Icon sizes (XS to XXL)
- Button sizes (S, M, L)
- Elevation levels (0-5)
- Touch targets (48dp minimum)
- Responsive breakpoints

### Typography (25+)
- Display styles (hero text)
- Headings (h1-h6)
- Body text (large, medium, small)
- Labels & buttons
- Specialized styles

### Theme
- Complete Material Design 3 theme
- 20+ pre-configured components
- Light & dark theme support

---

## 🎯 Design Principles

- **8pt Grid System** - Consistent visual rhythm
- **WCAG AA Compliant** - Accessible by default
- **Material Design 3** - Modern, professional
- **Touch-Optimized** - 48dp minimum targets
- **Type Scale** - Clear hierarchy

---

## 📖 Need Help?

Check the documentation files in this directory:
- Quick reference → `QUICK_START.md`
- Complete guide → `UI_UX_GUIDELINES.md`
- Migration help → `HARDCODED_VALUES_MIGRATION.md`

---

**Version**: 2.0.0  
**Status**: ✅ Production Ready  
**Last Updated**: December 2024
