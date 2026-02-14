import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

/// Modern video info card with education-friendly design
class VideoInfoCard extends StatelessWidget {

  const VideoInfoCard({
    super.key,
    required this.title,
    this.description,
    this.duration,
    this.position,
    this.onReplay,
    this.onShare,
  });
  final String title;
  final String? description;
  final Duration? duration;
  final Duration? position;
  final VoidCallback? onReplay;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.videoSurface,
            AppColors.videoSurfaceLight,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXL),
          topRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
          // Title
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spaceM),
          // Duration info
          if (duration != null && position != null)
            _buildProgressInfo(),
          const SizedBox(height: AppDimensions.spaceL),
          // Action buttons
          _buildActionButtons(),
          if (description != null) ...[
            const SizedBox(height: AppDimensions.spaceL),
            Divider(color: AppColors.white.withValues(alpha: 0.1)),
            const SizedBox(height: AppDimensions.spaceM),
            Text(
              'About this video',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressInfo() {
    final progressPercent = duration!.inMilliseconds > 0
        ? (position!.inMilliseconds / duration!.inMilliseconds * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: AppDimensions.borderRadiusM,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Progress circle
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progressPercent / 100,
                  strokeWidth: 4,
                  backgroundColor: AppColors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.videoPrimary,
                ),
                ),
                Text(
                  '$progressPercent%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          // Time info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXS),
                Text(
                  '${_formatDuration(position!)} / ${_formatDuration(duration!)}',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          // Remaining time
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
              vertical: AppDimensions.spaceS,
            ),
            decoration: BoxDecoration(
              color: AppColors.videoPrimarySubtle20,
              borderRadius: AppDimensions.borderRadiusS,
            ),
            child: Text(
              '-${_formatDuration(duration! - position!)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.videoPrimary,
                fontWeight: FontWeight.w600,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onReplay != null)
          Expanded(
            child: _ActionButton(
              icon: Icons.replay_rounded,
              label: 'Replay',
              onTap: onReplay!,
            ),
          ),
        if (onReplay != null && onShare != null)
          const SizedBox(width: AppDimensions.spaceM),
        if (onShare != null)
          Expanded(
            child: _ActionButton(
              icon: Icons.share_rounded,
              label: 'Share',
              onTap: onShare!,
              isPrimary: true,
            ),
          ),
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

/// Action button widget using centralized AnimatedButton.
///
/// Uses [AnimatedButton] for scale-tap animation,
/// eliminating duplicate animation code.
class _ActionButton extends StatelessWidget {

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      config: AnimationPresets.scaleButton, // 0.95 scale, same as original
      decoration: BoxDecoration(
        gradient: isPrimary
            ? AppColors.videoGradient
            : null,
        color: isPrimary ? null : AppColors.white.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusM,
        border: isPrimary
            ? null
            : Border.all(
                color: AppColors.white.withValues(alpha: 0.2),
              ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spaceM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.white,
            size: AppDimensions.iconS,
          ),
          const SizedBox(width: AppDimensions.spaceS),
          Text(
            label,
            style: AppTextStyles.button.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
