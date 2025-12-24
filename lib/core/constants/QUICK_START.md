# Quick Start Guide - Centralized Constants

## 🚀 Getting Started in 30 Seconds

### 1. Import Constants
```dart
import 'package:guardiancare/core/constants/constants.dart';
```

That's it! You now have access to all design system constants.

---

## 🎨 Most Common Use Cases

### Colors
```dart
// Primary actions
color: AppColors.primary

// Text
color: AppColors.textPrimary
color: AppColors.textSecondary

// Backgrounds
backgroundColor: AppColors.surface
backgroundColor: AppColors.cardBackground

// Semantic
color: AppColors.success  // Green
color: AppColors.error    // Red
color: AppColors.warning  // Amber
color: AppColors.info     // Blue
```

### Spacing
```dart
// Padding
padding: AppDimensions.paddingAllM        // 16px all sides
padding: AppDimensions.paddingHorizontalM // 16px horizontal
padding: AppDimensions.paddingVerticalS   // 8px vertical

// Margins
margin: EdgeInsets.all(AppDimensions.spaceM)
margin: EdgeInsets.symmetric(
  horizontal: AppDimensions.spaceM,
  vertical: AppDimensions.spaceS,
)

// Gaps
SizedBox(height: AppDimensions.spaceM)
SizedBox(width: AppDimensions.spaceS)
```

### Typography
```dart
// Headings
style: AppTextStyles.h1  // 32px, bold
style: AppTextStyles.h2  // 28px, bold
style: AppTextStyles.h3  // 24px, semibold
style: AppTextStyles.h4  // 20px, semibold

// Body text
style: AppTextStyles.bodyLarge   // 16px
style: AppTextStyles.bodyMedium  // 14px (most common)
style: AppTextStyles.bodySmall   // 12px

// Special
style: AppTextStyles.button
style: AppTextStyles.caption
```

### Border Radius
```dart
// Cards, buttons
borderRadius: AppDimensions.borderRadiusM  // 12px

// Modals, sheets
borderRadius: AppDimensions.borderRadiusL  // 16px

// Small elements
borderRadius: AppDimensions.borderRadiusS  // 8px

// Circular
borderRadius: AppDimensions.borderRadiusCircular
```

---

## 📦 Complete Widget Examples

### Button
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    padding: AppDimensions.buttonPadding,
    minimumSize: Size(
      AppDimensions.buttonMinWidth,
      AppDimensions.buttonHeight,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusM,
    ),
  ),
  child: Text('Click Me', style: AppTextStyles.button),
)
```

### Card
```dart
Card(
  margin: AppDimensions.paddingAllM,
  elevation: AppDimensions.cardElevation,
  color: AppColors.cardBackground,
  shape: RoundedRectangleBorder(
    borderRadius: AppDimensions.borderRadiusL,
  ),
  child: Padding(
    padding: AppDimensions.cardPaddingAll,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title', style: AppTextStyles.h4),
        SizedBox(height: AppDimensions.spaceS),
        Text('Content', style: AppTextStyles.bodyMedium),
      ],
    ),
  ),
)
```

### Input Field
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
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

### List Item
```dart
Card(
  margin: EdgeInsets.symmetric(
    horizontal: AppDimensions.spaceM,
    vertical: AppDimensions.spaceS,
  ),
  elevation: AppDimensions.elevation2,
  shape: RoundedRectangleBorder(
    borderRadius: AppDimensions.borderRadiusM,
  ),
  child: ListTile(
    contentPadding: AppDimensions.listItemPadding,
    leading: Icon(
      Icons.person,
      size: AppDimensions.iconL,
      color: AppColors.iconPrimary,
    ),
    title: Text('John Doe', style: AppTextStyles.h6),
    subtitle: Text(
      'john@example.com',
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
    trailing: Icon(
      Icons.arrow_forward_ios,
      size: AppDimensions.iconS,
      color: AppColors.iconSecondary,
    ),
  ),
)
```

### Dialog
```dart
AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: AppDimensions.borderRadiusL,
  ),
  backgroundColor: AppColors.surface,
  elevation: AppDimensions.dialogElevation,
  title: Text('Confirm', style: AppTextStyles.h4),
  content: Text(
    'Are you sure you want to continue?',
    style: AppTextStyles.bodyMedium,
  ),
  contentPadding: AppDimensions.dialogPadding,
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel', style: AppTextStyles.button),
    ),
    ElevatedButton(
      onPressed: () {},
      child: Text('Confirm', style: AppTextStyles.button),
    ),
  ],
)
```

---

## 🎯 Quick Reference Table

### Spacing Scale
| Value | Constant | Use Case |
|-------|----------|----------|
| 2px | `spaceXXS` | Tight spacing |
| 4px | `spaceXS` | Icon spacing |
| 8px | `spaceS` | Small gaps |
| 16px | `spaceM` | Default spacing |
| 24px | `spaceL` | Section spacing |
| 32px | `spaceXL` | Large gaps |
| 48px | `spaceXXL` | Major sections |

### Border Radius Scale
| Value | Constant | Use Case |
|-------|----------|----------|
| 4px | `radiusXS` | Subtle rounding |
| 8px | `radiusS` | Buttons, chips |
| 12px | `radiusM` | Cards, inputs |
| 16px | `radiusL` | Modals, sheets |
| 24px | `radiusXL` | Hero elements |

### Typography Scale
| Size | Constant | Use Case |
|------|----------|----------|
| 32px | `h1` | Page titles |
| 28px | `h2` | Section titles |
| 24px | `h3` | Subsections |
| 20px | `h4` | Card titles |
| 16px | `bodyLarge` | Emphasized text |
| 14px | `bodyMedium` | Default text |
| 12px | `bodySmall` | Small text |

---

## ⚡ Pro Tips

### 1. Use Theme Automatically
```dart
// Instead of manually styling every button
ElevatedButton(
  onPressed: () {},
  child: Text('Click Me'),
)
// Theme handles all styling automatically!
```

### 2. Customize with copyWith
```dart
Text(
  'Custom Text',
  style: AppTextStyles.bodyMedium.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  ),
)
```

### 3. Combine Constants
```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppDimensions.spaceM,
    vertical: AppDimensions.spaceS,
  ),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppDimensions.borderRadiusM,
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

### 4. Responsive Spacing
```dart
// Use MediaQuery for responsive layouts
final isSmallScreen = MediaQuery.of(context).size.width < 
                      AppDimensions.breakpointMobile;

padding: EdgeInsets.all(
  isSmallScreen ? AppDimensions.spaceS : AppDimensions.spaceM,
)
```

---

## 🚫 Common Mistakes to Avoid

### ❌ DON'T
```dart
// Hardcoded values
color: Colors.red
padding: EdgeInsets.all(16)
fontSize: 14
borderRadius: BorderRadius.circular(12)

// Magic numbers
SizedBox(height: 23)
margin: EdgeInsets.only(left: 17)
```

### ✅ DO
```dart
// Use constants
color: AppColors.error
padding: AppDimensions.paddingAllM
style: AppTextStyles.bodyMedium
borderRadius: AppDimensions.borderRadiusM

// Use design system values
SizedBox(height: AppDimensions.spaceL)
margin: EdgeInsets.only(left: AppDimensions.spaceM)
```

---

## 📱 Need Help?

### Documentation
- [Complete UI/UX Guidelines](./UI_UX_GUIDELINES.md)
- [Migration Guide](./HARDCODED_VALUES_MIGRATION.md)
- [Centralization Status](./CENTRALIZATION_STATUS.md)

### Quick Links
- Colors: `lib/core/constants/app_colors.dart`
- Dimensions: `lib/core/constants/app_dimensions.dart`
- Typography: `lib/core/constants/app_text_styles.dart`
- Theme: `lib/core/constants/app_theme.dart`

---

**Remember**: One import, infinite possibilities! 🎨

```dart
import 'package:guardiancare/core/constants/constants.dart';
```
