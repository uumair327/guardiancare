import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';
import 'package:intl/intl.dart';

/// Modern Forum Detail Page with educational-friendly design
///
/// Features:
/// - Gradient header with forum info
/// - Animated comments list
/// - Modern comment input
/// - Pull to refresh
class ForumDetailPage extends StatefulWidget {
  const ForumDetailPage({
    super.key,
    required this.forumId,
    required this.forumTitle,
    this.forumDescription,
    this.createdAt,
    this.userId,
  });

  final String forumId;
  final String forumTitle;
  final String? forumDescription;
  final DateTime? createdAt;
  final String? userId;

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final ValueNotifier<CommentEntity?> _replyingTo = ValueNotifier(null);

  @override
  void dispose() {
    _replyingTo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ForumBloc>()..add(LoadComments(widget.forumId)),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: context.colors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: _CommentsSection(
                    forumId: widget.forumId,
                    replyingTo: _replyingTo,
                    header: _ForumDetailHeader(
                      title: widget.forumTitle,
                      description: widget.forumDescription,
                      createdAt: widget.createdAt,
                      userId: widget.userId,
                    ),
                  ),
                ),
                CommentInput(
                  forumId: widget.forumId,
                  replyingTo: _replyingTo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Forum detail header with gradient and info
class _ForumDetailHeader extends StatefulWidget {
  const _ForumDetailHeader({
    required this.title,
    this.description,
    this.createdAt,
    this.userId,
  });
  final String title;
  final String? description;
  final DateTime? createdAt;
  final String? userId;

  @override
  State<_ForumDetailHeader> createState() => _ForumDetailHeaderState();
}

class _ForumDetailHeaderState extends State<_ForumDetailHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isExpanded = false;

  static Color get _primaryColor => AppColors.videoPrimary;
  static Color get _secondaryColor => AppColors.videoPrimaryDark;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationLong,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
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
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return UIStrings.justNow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryColor, _secondaryColor],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppDimensions.radiusXL),
            bottomRight: Radius.circular(AppDimensions.radiusXL),
          ),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: _slideAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with back button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spaceS,
                  AppDimensions.spaceS,
                  AppDimensions.screenPaddingH,
                  0,
                ),
                child: Row(
                  children: [
                    ScaleTapWidget(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.spaceS),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.white,
                          size: AppDimensions.iconM,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceS),
                    Expanded(
                      child: Text(
                        l10n.discussionTitle,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Share button
                    ScaleTapWidget(
                      onTap: HapticFeedback.lightImpact,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.spaceS),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPaddingH,
                  AppDimensions.spaceM,
                  AppDimensions.screenPaddingH,
                  AppDimensions.spaceL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: AppDimensions.borderRadiusS,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.forum_rounded,
                            size: 14,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.communityDiscussion,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    // Title
                    Text(
                      widget.title,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    // Description (expandable)
                    if (widget.description != null &&
                        widget.description!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spaceM),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isExpanded = !_isExpanded);
                        },
                        child: AnimatedCrossFade(
                          firstChild: Text(
                            widget.description!,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondChild: Text(
                            widget.description!,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                              height: 1.5,
                            ),
                          ),
                          crossFadeState: _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: AppDurations.animationShort,
                        ),
                      ),
                      if (widget.description!.length > 100)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: AppDimensions.spaceXS),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _isExpanded = !_isExpanded);
                            },
                            child: Row(
                              children: [
                                Text(
                                  _isExpanded
                                      ? UIStrings.showLess
                                      : UIStrings.showMore,
                                  style: AppTextStyles.caption.copyWith(
                                    color:
                                        AppColors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AnimatedRotation(
                                  turns: _isExpanded ? 0.5 : 0,
                                  duration: AppDurations.animationShort,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color:
                                        AppColors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: AppDimensions.spaceM),
                    // Meta info
                    Row(
                      children: [
                        if (widget.userId != null) ...[
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.userId!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        if (widget.createdAt != null) ...[
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTimeAgo(widget.createdAt!),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Comments section with threaded list
class _CommentsSection extends StatelessWidget {
  const _CommentsSection({
    required this.forumId,
    required this.replyingTo,
    required this.header,
  });

  final String forumId;
  final ValueNotifier<CommentEntity?> replyingTo;
  final Widget header;

  static Color get _primaryColor => AppColors.videoPrimary;

  List<_CommentDisplayItem> _flattenComments(List<CommentEntity> comments) {
    final Map<String?, List<CommentEntity>> byParent = {};
    for (final c in comments) {
      byParent.putIfAbsent(c.parentId, () => []).add(c);
    }

    final List<_CommentDisplayItem> result = [];
    void traverse(String? parentId, int depth) {
      final children = byParent[parentId] ?? [];
      // Sort by creation time (oldest first for thread readability)
      children.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final child in children) {
        result.add(_CommentDisplayItem(child, depth));
        traverse(child.id, depth + 1);
      }
    }

    traverse(null, 0);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ForumBloc, ForumState>(
      listener: (context, state) {
        if (state is ForumError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.white, size: 20),
                  const SizedBox(width: AppDimensions.spaceS),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusM,
              ),
              duration: AppDurations.snackbarMedium,
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        return current is ForumLoading ||
            current is CommentsLoaded ||
            current is ForumError;
      },
      builder: (context, state) {
        if (state is ForumLoading) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              header,
              const SizedBox(height: AppDimensions.spaceM),
              _buildLoadingState(),
            ],
          );
        }

        if (state is CommentsLoaded && state.forumId == forumId) {
          if (state.comments.isEmpty) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                header,
                const SizedBox(height: AppDimensions.spaceM),
                _buildEmptyState(context, l10n),
              ],
            );
          }

          final displayItems = _flattenComments(state.comments);

          return RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              context.read<ForumBloc>().add(LoadComments(forumId));
              await Future.delayed(AppDurations.animationMedium);
            },
            color: _primaryColor,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: displayItems.length + 2, // +1 Header, +1 Count
              itemBuilder: (context, index) {
                if (index == 0) {
                  return header;
                }
                if (index == 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPaddingH,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spaceM),
                      child: _buildCommentsHeader(
                          context, state.comments.length, l10n),
                    ),
                  );
                }
                final item = displayItems[index - 2];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPaddingH,
                  ),
                  child: CommentItem(
                    comment: item.comment,
                    index: index - 2,
                    depth: item.depth,
                    onReply: () {
                      HapticFeedback.selectionClick();
                      replyingTo.value = item.comment;
                    },
                  ),
                );
              },
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            header,
            const SizedBox(height: AppDimensions.spaceM),
            _buildLoadingState(),
          ],
        );
      },
    );
  }

  Widget _buildCommentsHeader(
      BuildContext context, int count, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spaceS),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.1),
            borderRadius: AppDimensions.borderRadiusS,
          ),
          child: Icon(
            Icons.chat_bubble_rounded,
            color: _primaryColor,
            size: 18,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceS),
        Text(
          l10n.commentsCount(count),
          style: AppTextStyles.h4.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        5,
        (index) => FadeSlideWidget(
          duration: AppDurations.animationShort,
          delay: Duration(milliseconds: 50 * index),
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.spaceM,
              left: AppDimensions.screenPaddingH,
              right: AppDimensions.screenPaddingH,
            ),
            child: ShimmerLoading(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: AppDimensions.borderRadiusL,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return FadeSlideWidget(
      duration: AppDurations.animationMedium,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceXL),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: AppDimensions.iconXXL,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              l10n.noCommentsYet,
              style: AppTextStyles.h4.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              l10n.beFirstToComment,
              style: AppTextStyles.body2.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceM,
                vertical: AppDimensions.spaceS,
              ),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusM,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.startTypingBelow,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentDisplayItem {

  _CommentDisplayItem(this.comment, this.depth);
  final CommentEntity comment;
  final int depth;
}
