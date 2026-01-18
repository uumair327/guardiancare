import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

/// Modern video control button with education-friendly design.
///
/// Uses centralized [AnimatedButton] for scale-tap animation,
/// eliminating duplicate animation code.
class VideoControlButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color? color;
  final double size;
  final bool showLabel;

  const VideoControlButton({
    super.key,
    required this.icon,
    this.label,
    required this.onTap,
    this.color,
    this.size = 32,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.white;

    return AnimatedButton(
      onTap: onTap,
      config: AnimationPresets.scaleLarge, // 0.9 scale, same as original
      enableHaptic: true,
      hapticType: HapticFeedbackType.light,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceM,
        vertical: AppDimensions.spaceS,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spaceS),
            decoration: BoxDecoration(
              color: buttonColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: buttonColor,
              size: size,
            ),
          ),
          if (showLabel && label != null) ...[
            SizedBox(height: AppDimensions.spaceXS),
            Text(
              label!,
              style: AppTextStyles.caption.copyWith(
                color: buttonColor.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Main play/pause button with animated icon.
///
/// Uses centralized [AnimatedButton.circular] for scale-tap animation,
/// eliminating duplicate animation code.
class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final double size;

  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    // Custom config for 0.85 scale (slightly more than scaleLarge's 0.9)
    final playPauseConfig = AnimationPresets.scaleLarge.copyWith(end: 0.85);

    return AnimatedButton.circular(
      size: size,
      onTap: onTap,
      config: playPauseConfig,
      enableHaptic: true,
      hapticType: HapticFeedbackType.medium,
      boxShadow: [
        BoxShadow(
          color: AppColors.videoPrimarySubtle40,
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppColors.videoGradient,
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: AppDurations.animationShort,
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(isPlaying),
            color: AppColors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

/// Seek button for forward/backward
class SeekButton extends StatelessWidget {
  final int seconds;
  final bool isForward;
  final VoidCallback onTap;
  final IconData? icon;
  final bool showLabel;

  const SeekButton({
    super.key,
    this.seconds = 10,
    this.isForward = false,
    required this.onTap,
    this.icon,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return VideoControlButton(
      icon: icon ?? (isForward ? Icons.forward_10_rounded : Icons.replay_10_rounded),
      label: showLabel ? '${isForward ? '+' : '-'}${seconds}s' : null,
      onTap: onTap,
      showLabel: showLabel,
    );
  }
}
