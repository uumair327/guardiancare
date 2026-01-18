import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Education-friendly bottom navigation bar
/// Features smooth animations, vibrant colors, and engaging design
class BottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: AppDurations.animationShort,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.9).animate(
        CurvedAnimation(parent: controller, curve: AppCurves.tap),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTap(int index) {
    HapticFeedback.lightImpact();
    _controllers[index].forward().then((_) {
      _controllers[index].reverse();
    });
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppDimensions.spaceM,
        0,
        AppDimensions.spaceM,
        AppDimensions.spaceM,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppDimensions.borderRadiusXL,
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppDimensions.borderRadiusXL,
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceM,
            vertical: AppDimensions.spaceS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (index) {
              return _NavItemWidget(
                item: widget.items[index],
                isSelected: widget.currentIndex == index,
                onTap: () => _onItemTap(index),
                scaleAnimation: _scaleAnimations[index],
                controller: _controllers[index],
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item widget
class _NavItemWidget extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double> scaleAnimation;
  final AnimationController controller;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.scaleAnimation,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          width: 64,
          height: 56,
          child: Center(
            child: AnimatedContainer(
              duration: AppDurations.animationMedium,
              curve: AppCurves.emphasized,
              padding: EdgeInsets.all(AppDimensions.spaceS),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          item.activeColor ?? context.colors.primary,
                          (item.activeColor ?? context.colors.primary)
                              .withValues(alpha: 0.8),
                        ],
                      )
                    : null,
                borderRadius: AppDimensions.borderRadiusM,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (item.activeColor ?? context.colors.primary)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color:
                    isSelected ? AppColors.white : context.colors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation item data model
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color? activeColor;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.activeColor,
  });
}

/// Floating action button style bottom nav (alternative design)
class FloatingBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorController;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
  }

  @override
  void didUpdateWidget(FloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _indicatorController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppDimensions.spaceL,
        0,
        AppDimensions.spaceL,
        AppDimensions.spaceL,
      ),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colors.surface,
              context.colors.surface.withValues(alpha: 0.98),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.items.length, (index) {
            final isSelected = widget.currentIndex == index;
            final item = widget.items[index];

            return _FloatingNavItem(
              item: item,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap(index);
              },
            );
          }),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void didUpdateWidget(_FloatingNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.item.activeColor ?? context.colors.primary;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = _controller.value < 0.5
              ? _scaleAnimation.value
              : _bounceAnimation.value;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: SizedBox(
          width: 56,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppDurations.animationMedium,
                curve: AppCurves.emphasized,
                padding: EdgeInsets.all(widget.isSelected ? 10 : 8),
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color,
                            color.withValues(alpha: 0.8),
                          ],
                        )
                      : null,
                  color: widget.isSelected ? null : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                  color: widget.isSelected
                      ? AppColors.white
                      : context.colors.textSecondary,
                  size: widget.isSelected ? 22 : 24,
                ),
              ),
              if (widget.isSelected) ...[
                SizedBox(height: 2),
                Container(
                  width: 4,
                  height: 4,
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

// Keep backward compatibility aliases
typedef ModernBottomNav = BottomNav;
typedef ModernNavItem = NavItem;
