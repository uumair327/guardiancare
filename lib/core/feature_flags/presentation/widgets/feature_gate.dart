import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/feature_flags/presentation/cubit/feature_flag_cubit.dart';

/// Conditionally renders [child] only when [flagKey] is enabled.
///
/// When the flag is disabled, shows [disabledChild] if provided,
/// otherwise renders nothing (SizedBox.shrink).
///
/// Changes propagate in real-time — no page reload needed.
///
/// ## Example — hide the forum tab
/// ```dart
/// FeatureGate(
///   flagKey: FeatureFlagKeys.forum,
///   child: ForumPage(),
///   disabledChild: FeatureDisabledPlaceholder(
///     label: 'Forum',
///     message: 'The forum is temporarily unavailable.',
///   ),
/// )
/// ```
class FeatureGate extends StatelessWidget {
  const FeatureGate({
    super.key,
    required this.flagKey,
    required this.child,
    this.disabledChild,
  });

  /// The feature flag key to check — use [FeatureFlagKeys] constants.
  final String flagKey;

  /// Widget shown when the flag is enabled.
  final Widget child;

  /// Widget shown when the flag is disabled.
  /// Defaults to [SizedBox.shrink] (invisible).
  final Widget? disabledChild;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FeatureFlagCubit, FeatureFlagState, bool>(
      selector: (state) {
        if (state is FeatureFlagLoaded) return state.isEnabled(flagKey);
        // While loading, show the feature (fail-open = better UX)
        return true;
      },
      builder: (context, isEnabled) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isEnabled ? child : (disabledChild ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

/// Standard placeholder shown when a feature is disabled.
/// Use inside [FeatureGate.disabledChild] for a consistent look.
class FeatureDisabledPlaceholder extends StatelessWidget {
  const FeatureDisabledPlaceholder({
    super.key,
    required this.label,
    this.message = 'This feature is temporarily unavailable.',
    this.icon = Icons.block_rounded,
  });

  final String label;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              '$label Unavailable',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
