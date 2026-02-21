import 'package:flutter/material.dart';
import 'package:guardiancare/core/responsive/responsive_breakpoints.dart';
import 'package:guardiancare/core/responsive/responsive_context.dart';

/// Wraps content in a centred, max-width container on wider screens.
///
/// On mobile, renders [child] with full width.
/// On tablet+, constrains to [maxWidth] and centres it horizontally.
///
/// ```dart
/// ResponsiveContainer(
///   child: Column(children: [...]),
/// )
/// ```
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContent,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final horizontalPad =
        padding ?? EdgeInsets.symmetric(horizontal: context.responsivePaddingH);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: horizontalPad,
          child: child,
        ),
      ),
    );
  }
}

/// Chooses between [mobile], [tablet], or [desktop] widget based on width.
///
/// Only the selected branch is built.
///
/// ```dart
/// ResponsiveBuilder(
///   mobile: const MobileNav(),
///   desktop: const SideNav(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.widescreen,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? widescreen;

  @override
  Widget build(BuildContext context) {
    return context.responsiveValue<Widget>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      widescreen: widescreen,
    );
  }
}

/// Adaptive grid that adjusts column count based on screen width.
///
/// ```dart
/// ResponsiveGrid(
///   mobileColumns: 1,
///   tabletColumns: 2,
///   desktopColumns: 3,
///   children: cards,
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.widescreenColumns,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.childAspectRatio = 1.0,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int? widescreenColumns;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final columns = context.responsiveValue<int>(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      widescreen: widescreenColumns ?? desktopColumns,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (_, i) => children[i],
    );
  }
}

/// Side navigation layout used on desktop/widescreen.
///
/// Shows [sideNav] on the left (fixed width [sideNavWidth]) and
/// [body] as the expanding content area.
/// On mobile/tablet, falls back to [body] only (the caller manages nav separately).
///
/// ```dart
/// ResponsiveSideNavLayout(
///   sideNav: const AppSideNav(),
///   body: const HomeContent(),
/// )
/// ```
class ResponsiveSideNavLayout extends StatelessWidget {
  const ResponsiveSideNavLayout({
    super.key,
    required this.sideNav,
    required this.body,
    this.sideNavWidth = 240,
  });

  final Widget sideNav;
  final Widget body;
  final double sideNavWidth;

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktopOrLarger) {
      return body;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: sideNavWidth, child: sideNav),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(child: body),
      ],
    );
  }
}
