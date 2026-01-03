import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';
import 'package:intl/intl.dart';

/// Comment Item with educational-friendly design
/// 
/// Features:
/// - Animated appearance
/// - User avatar with gradient
/// - Time ago display
/// - Subtle interactions
/// - Fetches user display name from Firestore
class CommentItem extends StatefulWidget {
  final CommentEntity comment;
  final int index;

  const CommentItem({
    super.key,
    required this.comment,
    this.index = 0,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isExpanded = false;
  String? _userName;
  String? _userImage;
  bool _isLoadingUser = true;

  static const _primaryColor = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final result = await sl<GetUserDetails>()(
        GetUserDetailsParams(userId: widget.comment.userId),
      );
      if (mounted) {
        setState(() {
          result.fold(
            (failure) {
              _userName = null;
              _userImage = null;
            },
            (userDetails) {
              _userName = userDetails.userName;
              _userImage = userDetails.userImage.isNotEmpty 
                  ? userDetails.userImage 
                  : null;
            },
          );
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  /// Gets the display name - uses fetched name or falls back to "User"
  String get _displayName {
    if (_userName != null && _userName!.isNotEmpty) {
      return _userName!;
    }
    return 'User';
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

  Color _getAvatarColor(String userId) {
    final colors = [
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFF6366F1),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
    ];
    return colors[userId.hashCode.abs() % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _buildAvatar(Color avatarColor, String displayName) {
    // Show loading state
    if (_isLoadingUser) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.gray200,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray400),
            ),
          ),
        ),
      );
    }

    // Show profile photo if available
    if (_userImage != null && _userImage!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: avatarColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            _userImage!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to initials on error
              return _buildInitialsAvatar(avatarColor, displayName);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(avatarColor),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // Fallback to initials
    return _buildInitialsAvatar(avatarColor, displayName);
  }

  Widget _buildInitialsAvatar(Color avatarColor, String displayName) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            avatarColor,
            avatarColor.withValues(alpha: 0.7),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: avatarColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getInitials(displayName),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor(widget.comment.userId);
    final isLongComment = widget.comment.text.length > 200;
    final displayName = _displayName;

    return RepaintBoundary(
      child: FadeSlideWidget(
        duration: AppDurations.animationMedium,
        delay: Duration(milliseconds: 50 * widget.index),
        direction: SlideDirection.up,
        slideOffset: 15,
        child: Container(
          margin: EdgeInsets.only(bottom: AppDimensions.spaceM),
          padding: EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppDimensions.borderRadiusL,
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // User Avatar - shows profile photo or initials
                  _buildAvatar(avatarColor, displayName),
                  SizedBox(width: AppDimensions.spaceS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isLoadingUser
                            ? Container(
                                width: 80,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.gray200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )
                            : Text(
                                displayName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              _getTimeAgo(widget.comment.createdAt),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryColor.withValues(alpha: 0.1),
                      borderRadius: AppDimensions.borderRadiusS,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 12,
                          color: _primaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          ForumStrings.member,
                          style: AppTextStyles.caption.copyWith(
                            color: _primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spaceM),
              AnimatedCrossFade(
                firstChild: Text(
                  widget.comment.text,
                  style: AppTextStyles.body2.copyWith(
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Text(
                  widget.comment.text,
                  style: AppTextStyles.body2.copyWith(
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: AppDurations.animationShort,
              ),
              if (isLongComment) ...[
                SizedBox(height: AppDimensions.spaceS),
                ScaleTapWidget(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isExpanded = !_isExpanded);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isExpanded ? UIStrings.showLess : UIStrings.showMore,
                        style: AppTextStyles.caption.copyWith(
                          color: _primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: AppDurations.animationShort,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: _primaryColor,
                        ),
                      ),
                    ],
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
