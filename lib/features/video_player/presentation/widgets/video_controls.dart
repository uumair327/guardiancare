import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Modern video control button with education-friendly design
class VideoControlButton extends StatefulWidget {
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
  State<VideoControlButton> createState() => _VideoControlButtonState();
}

class _VideoControlButtonState extends State<VideoControlButton>
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
    final buttonColor = widget.color ?? AppColors.white;

    return GestureDetector(
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
                  widget.icon,
                  color: buttonColor,
                  size: widget.size,
                ),
              ),
              if (widget.showLabel && widget.label != null) ...[
                SizedBox(height: AppDimensions.spaceXS),
                Text(
                  widget.label!,
                  style: AppTextStyles.caption.copyWith(
                    color: buttonColor.withValues(alpha: 0.8),
                    fontSize: 10,
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

/// Main play/pause button with animated icon
class PlayPauseButton extends StatefulWidget {
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
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.mediumImpact();
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
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF8B5CF6),
                const Color(0xFF7C3AED),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: AppDurations.animationShort,
            child: Icon(
              widget.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              key: ValueKey(widget.isPlaying),
              color: AppColors.white,
              size: widget.size * 0.5,
            ),
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
