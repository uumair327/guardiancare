import 'package:flutter/material.dart';

import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/core/constants/app_dimensions.dart';
import 'package:guardiancare/core/constants/app_durations.dart';
import 'package:guardiancare/core/constants/app_strings.dart';
import 'package:guardiancare/core/constants/app_text_styles.dart';
import 'package:guardiancare/core/widgets/bottom_nav.dart';

/// Desktop/widescreen vertical side navigation.
///
/// Mirrors the items from [ModernBottomNav]/[NavItem] so the same
/// data model drives both navigations — no duplication.
///
/// Use [ResponsiveBuilder] in [Pages] to switch between this and
/// the bottom nav based on screen size.
class DesktopSideNav extends StatelessWidget {
  const DesktopSideNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.width = 220,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : AppColors.white,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Brand Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceM,
                AppDimensions.spaceL,
                AppDimensions.spaceM,
                AppDimensions.spaceL,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceS),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: AppDimensions.borderRadiusM,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceS),
                  Expanded(
                    child: Text(
                      AppStrings.appName,
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),
            const SizedBox(height: AppDimensions.spaceS),

            // ── Nav Items ────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceS,
                  vertical: AppDimensions.spaceS,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _SideNavItem(
                    item: items[index],
                    isSelected: currentIndex == index,
                    onTap: () => onTap(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Side Nav Item ─────────────────────────────────────────────────────────────

class _SideNavItem extends StatefulWidget {
  const _SideNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.item.activeColor ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.animationShort,
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: AppDimensions.spaceXS),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceM,
            vertical: AppDimensions.spaceS + 2,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? color.withValues(alpha: 0.12)
                : _hovered
                    ? AppColors.gray100.withValues(alpha: 0.5)
                    : Colors.transparent,
            borderRadius: AppDimensions.borderRadiusM,
            border: widget.isSelected
                ? Border.all(color: color.withValues(alpha: 0.25))
                : null,
          ),
          child: Row(
            children: [
              // Icon
              AnimatedContainer(
                duration: AppDurations.animationShort,
                padding: const EdgeInsets.all(AppDimensions.spaceXS),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: AppDimensions.borderRadiusS,
                ),
                child: Icon(
                  widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                  color: widget.isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: AppDimensions.iconM,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceS),
              // Label
              Expanded(
                child: Text(
                  widget.item.label,
                  style: AppTextStyles.body1.copyWith(
                    color: widget.isSelected
                        ? color
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight:
                        widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Selected indicator dot
              if (widget.isSelected) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
