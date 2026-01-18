import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';
import 'package:intl/intl.dart';

/// Forum List Item with educational-friendly design
///
/// Features:
/// - 3D tilt effect on touch
/// - Gradient accent with category colors
/// - Animated interactions
/// - Educational badges
/// - Performance optimized with RepaintBoundary
class ForumListItem extends StatefulWidget {
  final ForumEntity forum;
  final int index;

  const ForumListItem({
    super.key,
    required this.forum,
    this.index = 0,
  });

  @override
  State<ForumListItem> createState() => _ForumListItemState();
}

class _ForumListItemState extends State<ForumListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;
  Offset _tiltOffset = Offset.zero;

  // Educational-friendly purple color palette - using centralized colors
  static Color get _primaryColor => AppColors.videoPrimary;
  static Color get _secondaryColor => AppColors.videoPrimaryDark;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTap() {
    final forumData = {
      'title': widget.forum.title,
      'description': widget.forum.description,
      'createdAt': widget.forum.createdAt.toIso8601String(),
      'userId': widget.forum.userId,
    };
    context.push('/forum/${widget.forum.id}', extra: forumData);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final localPosition = details.localPosition;

    final dx = (localPosition.dx - size.width / 2) / (size.width / 2);
    final dy = (localPosition.dy - size.height / 2) / (size.height / 2);

    setState(() {
      _tiltOffset = Offset(
        dy.clamp(-1.0, 1.0) * 0.015,
        -dx.clamp(-1.0, 1.0) * 0.015,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _tiltOffset = Offset.zero);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return UIStrings.justNow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: AppDurations.animationShort,
                curve: AppCurves.standard,
                margin: EdgeInsets.only(bottom: AppDimensions.spaceM),
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_tiltOffset.dx)
                  ..rotateY(_tiltOffset.dy),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: AppDimensions.borderRadiusL,
                  border: Border.all(
                    color: _isPressed
                        ? _primaryColor.withValues(alpha: 0.3)
                        : context.colors.divider.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withValues(
                        alpha: _isPressed ? 0.15 : 0.08,
                      ),
                      blurRadius: _isPressed ? 16 : 12,
                      offset: Offset(
                        _tiltOffset.dy * 6,
                        _tiltOffset.dx * 6 + (_isPressed ? 2 : 4),
                      ),
                      spreadRadius: _isPressed ? 0 : 1,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: AppDimensions.borderRadiusL,
            child: Stack(
              children: [
                // Gradient accent bar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_primaryColor, _secondaryColor],
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.only(
                    left: AppDimensions.spaceM + 4,
                    right: AppDimensions.spaceM,
                    top: AppDimensions.spaceM,
                    bottom: AppDimensions.spaceM,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row with title and arrow
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question icon
                          Container(
                            padding: EdgeInsets.all(AppDimensions.spaceS),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _primaryColor.withValues(alpha: 0.15),
                                  _secondaryColor.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: AppDimensions.borderRadiusS,
                            ),
                            child: Icon(
                              Icons.question_answer_rounded,
                              color: _primaryColor,
                              size: AppDimensions.iconS,
                            ),
                          ),
                          SizedBox(width: AppDimensions.spaceS),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.forum.title,
                                  style: AppTextStyles.h4.copyWith(
                                    color: context.colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: AppDimensions.spaceXS),
                                // Author and time
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 14,
                                      color: context.colors.textSecondary,
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        widget.forum.userId,
                                        style: AppTextStyles.caption.copyWith(
                                          color: context.colors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 6),
                                      width: 3,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: context.colors.textSecondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 14,
                                      color: context.colors.textSecondary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      _getTimeAgo(widget.forum.createdAt),
                                      style: AppTextStyles.caption.copyWith(
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: AppDimensions.spaceS),
                          // Arrow indicator
                          AnimatedContainer(
                            duration: AppDurations.animationShort,
                            padding: EdgeInsets.all(AppDimensions.spaceXS),
                            decoration: BoxDecoration(
                              color: _isPressed
                                  ? _primaryColor.withValues(alpha: 0.2)
                                  : _primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: _primaryColor,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spaceM),
                      // Description
                      Text(
                        widget.forum.description,
                        style: AppTextStyles.body2.copyWith(
                          height: 1.5,
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppDimensions.spaceM),
                      // Bottom row with badges
                      Row(
                        children: [
                          _buildBadge(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: ForumStrings.discussion,
                            color: _primaryColor,
                          ),
                          SizedBox(width: AppDimensions.spaceS),
                          _buildBadge(
                            icon: Icons.family_restroom_rounded,
                            label: ForumStrings.family,
                            color: AppColors.cardEmerald,
                          ),
                          const Spacer(),
                          Text(
                            ForumStrings.tapToJoin,
                            style: AppTextStyles.caption.copyWith(
                              color: _primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
