import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/video_player/presentation/constants/strings.dart';

/// Playback speed selector with education-friendly design
class PlaybackSpeedSelector extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;

  const PlaybackSpeedSelector({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  static const List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppDimensions.spaceS,
              bottom: AppDimensions.spaceM,
            ),
            child: Text(
              VideoPlayerStrings.playbackSpeed,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Wrap(
            spacing: AppDimensions.spaceS,
            runSpacing: AppDimensions.spaceS,
            children: _speeds.map((speed) {
              return _SpeedChip(
                speed: speed,
                isSelected: currentSpeed == speed,
                onTap: () => onSpeedChanged(speed),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SpeedChip extends StatefulWidget {
  final double speed;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeedChip({
    required this.speed,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SpeedChip> createState() => _SpeedChipState();
}

class _SpeedChipState extends State<_SpeedChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatSpeed(double speed) {
    if (speed == 1.0) return VideoPlayerStrings.normal;
    return '${speed}x';
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: AppDurations.animationShort,
            curve: AppCurves.standard,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
              vertical: AppDimensions.spaceS,
            ),
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                    )
                  : null,
              color: widget.isSelected
                  ? null
                  : AppColors.white.withValues(alpha: 0.08),
              borderRadius: AppDimensions.borderRadiusM,
              border: Border.all(
                color: widget.isSelected
                    ? Colors.transparent
                    : AppColors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              _formatSpeed(widget.speed),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact speed button for inline use
class PlaybackSpeedButton extends StatefulWidget {
  final double currentSpeed;
  final VoidCallback onTap;

  const PlaybackSpeedButton({
    super.key,
    required this.currentSpeed,
    required this.onTap,
  });

  @override
  State<PlaybackSpeedButton> createState() => _PlaybackSpeedButtonState();
}

class _PlaybackSpeedButtonState extends State<PlaybackSpeedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
              vertical: AppDimensions.spaceS,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: AppDimensions.borderRadiusS,
            ),
            child: Text(
              widget.currentSpeed == 1.0 ? '1x' : '${widget.currentSpeed}x',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
