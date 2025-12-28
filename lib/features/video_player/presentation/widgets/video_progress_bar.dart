import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/video_player/domain/entities/video_entity.dart';

/// Modern video progress bar with education-friendly design
class VideoProgressBar extends StatefulWidget {
  final VideoProgress progress;
  final ValueChanged<Duration>? onSeek;
  final bool showTimeLabels;
  final Color? progressColor;
  final Color? bufferedColor;
  final Color? backgroundColor;

  const VideoProgressBar({
    super.key,
    required this.progress,
    this.onSeek,
    this.showTimeLabels = true,
    this.progressColor,
    this.bufferedColor,
    this.backgroundColor,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    final progressColor = widget.progressColor ?? const Color(0xFF8B5CF6);
    final bufferedColor = widget.bufferedColor ?? AppColors.white.withValues(alpha: 0.3);
    final backgroundColor = widget.backgroundColor ?? AppColors.white.withValues(alpha: 0.15);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        GestureDetector(
          onHorizontalDragStart: (details) {
            setState(() {
              _isDragging = true;
              _dragValue = widget.progress.progressPercent;
            });
            HapticFeedback.selectionClick();
          },
          onHorizontalDragUpdate: (details) {
            final box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            setState(() {
              _dragValue = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
            });
          },
          onHorizontalDragEnd: (details) {
            if (widget.onSeek != null) {
              final seekPosition = Duration(
                milliseconds: (_dragValue * widget.progress.total.inMilliseconds).round(),
              );
              widget.onSeek!(seekPosition);
            }
            setState(() {
              _isDragging = false;
            });
            HapticFeedback.lightImpact();
          },
          onTapUp: (details) {
            final box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            final tapPercent = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
            if (widget.onSeek != null) {
              final seekPosition = Duration(
                milliseconds: (tapPercent * widget.progress.total.inMilliseconds).round(),
              );
              widget.onSeek!(seekPosition);
            }
            HapticFeedback.lightImpact();
          },
          child: Container(
            height: 32,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background track
                Container(
                  height: _isDragging ? 8 : 4,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Buffered track
                AppAnimatedContainer(
                  height: _isDragging ? 8 : 4,
                  width: double.infinity,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.progress.bufferedPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bufferedColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                // Progress track
                AppAnimatedContainer(
                  duration: _isDragging 
                      ? Duration.zero 
                      : null, // Uses default AppDurations.animationShort when not dragging
                  height: _isDragging ? 8 : 4,
                  width: double.infinity,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _isDragging 
                        ? _dragValue 
                        : widget.progress.progressPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor,
                            progressColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: progressColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Thumb
                AnimatedPositioned(
                  duration: _isDragging 
                      ? Duration.zero 
                      : AppDurations.animationShort,
                  left: (_isDragging 
                      ? _dragValue 
                      : widget.progress.progressPercent) * 
                      (MediaQuery.of(context).size.width - 48) - 8,
                  child: AppAnimatedContainer(
                    duration: _isDragging ? Duration.zero : null, // Uses default when not dragging
                    width: _isDragging ? 20 : 16,
                    height: _isDragging ? 20 : 16,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: _isDragging ? 2 : 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Time labels
        if (widget.showTimeLabels) ...[
          SizedBox(height: AppDimensions.spaceXS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_isDragging 
                    ? Duration(
                        milliseconds: (_dragValue * widget.progress.total.inMilliseconds).round(),
                      )
                    : widget.progress.position),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              Text(
                _formatDuration(widget.progress.total),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white.withValues(alpha: 0.6),
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
