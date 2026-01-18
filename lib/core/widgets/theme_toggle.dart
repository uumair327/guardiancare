import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/core/constants/app_dimensions.dart';
import 'package:guardiancare/core/managers/theme_manager.dart';
import 'package:guardiancare/core/di/di.dart' as di;

/// Premium animated theme toggle widget
/// Features:
/// - Smooth sun/moon icon transition
/// - Material 3 styling
/// - Haptic feedback
/// - Accessible labels
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = di.sl<ThemeManager>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          themeManager.toggleTheme();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: AppDimensions.paddingAllS,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.8)
                : AppColors.gray100,
            borderRadius: AppDimensions.borderRadiusL,
            border: Border.all(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.gray200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.primary : AppColors.gray400)
                    .withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sun/Moon Icon with animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey(isDark),
                  color: isDark ? AppColors.primary : AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              // Theme label
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  isDark ? 'Dark' : 'Light',
                  key: ValueKey(isDark ? 'dark' : 'light'),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Theme toggle for settings/profile page with tile layout
class ThemeSettingsTile extends StatelessWidget {
  const ThemeSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = di.sl<ThemeManager>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: AppDimensions.paddingHorizontalM,
      child: Padding(
        padding: AppDimensions.paddingAllM,
        child: Row(
          children: [
            // Icon
            Container(
              padding: AppDimensions.paddingAllS,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: AppDimensions.borderRadiusM,
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: colorScheme.primary,
                size: AppDimensions.iconM,
              ),
            ),
            const SizedBox(width: 16),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDark ? 'Dark mode enabled' : 'Light mode enabled',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            // Toggle switch
            Switch.adaptive(
              value: isDark,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                themeManager.changeTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
              thumbColor: WidgetStateProperty.all(colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
