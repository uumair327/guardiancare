import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/core/constants/app_dimensions.dart';

/// Glassmorphism effect container
/// 
/// Features:
/// - Frosted glass effect with blur
/// - Customizable opacity and blur
/// - Border glow effect
/// - Performance optimized with RepaintBoundary
class GlassmorphicContainer extends StatelessWidget {

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
  });
  final Widget child;
  final double blur;
  final double opacity;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDimensions.borderRadiusL;
    final bgColor = backgroundColor ?? AppColors.white;
    final border = borderColor ?? AppColors.white.withValues(alpha: 0.3);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            padding: padding ?? AppDimensions.paddingAllM,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor.withValues(alpha: opacity + 0.1),
                  bgColor.withValues(alpha: opacity),
                ],
              ),
              borderRadius: radius,
              border: Border.all(
                color: border,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glassmorphic card with elevation effect
class GlassmorphicCard extends StatelessWidget {

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.15,
    this.tintColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
  });
  final Widget child;
  final double blur;
  final double opacity;
  final Color? tintColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDimensions.borderRadiusL;
    final tint = tintColor ?? AppColors.white;

    return RepaintBoundary(
      child: Container(
        margin: margin ?? AppDimensions.paddingAllS,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  padding: padding ?? AppDimensions.paddingAllM,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tint.withValues(alpha: opacity + 0.1),
                        tint.withValues(alpha: opacity * 0.5),
                      ],
                    ),
                    borderRadius: radius,
                    border: Border.all(
                      color: tint.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted glass overlay for modals and dialogs
class FrostedGlassOverlay extends StatelessWidget {

  const FrostedGlassOverlay({
    super.key,
    required this.child,
    this.blur = 5.0,
    this.overlayColor = Colors.black,
    this.overlayOpacity = 0.3,
  });
  final Widget child;
  final double blur;
  final Color overlayColor;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              color: overlayColor.withValues(alpha: overlayOpacity),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
