import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocProvider(
      create: (context) => sl<ForumBloc>()..add(const LoadForums(ForumCategory.parent)),
      child: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.forums),
                bottom: TabBar(
                  onTap: (index) {
                    final category = index == 0 ? ForumCategory.parent : ForumCategory.children;
                    context.read<ForumBloc>().add(LoadForums(category));
                  },
                  tabs: [
                    Tab(text: l10n.parentGuardian),
                    Tab(text: l10n.child),
                  ],
                ),
              ),
              body: SafeArea(
                child: const TabBarView(
                children: [
                  _ForumListView(category: ForumCategory.parent),
                  _ForumListView(category: ForumCategory.children),
                ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}

class _ForumListView extends StatelessWidget {
  final ForumCategory category;

  const _ForumListView({required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocConsumer<ForumBloc, ForumState>(
      listener: (context, state) {
        if (state is ForumError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: AppDurations.snackbarMedium,
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        // Always rebuild to ensure UI updates
        return true;
      },
      builder: (context, state) {
        print('ForumListView: Building with state: ${state.runtimeType} for category: $category');
        
        if (state is ForumLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ForumsLoaded) {
          print('ForumListView: Forums loaded - ${state.forums.length} forums for ${state.category}');
          
          // Only show forums for this category
          if (state.category != category) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state.forums.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: AppDimensions.iconXXL,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppDimensions.spaceM),
                  Text(
                    l10n.noForumsAvailable,
                    style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    l10n.noCommentsYet,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ForumBloc>().add(RefreshForums(category));
              await Future.delayed(AppDurations.animationMedium);
            },
            child: ListView.builder(
              itemCount: state.forums.length,
              padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceS),
              itemBuilder: (context, index) {
                return ForumListItem(forum: state.forums[index]);
              },
            ),
          );
        }

        if (state is ForumError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: AppDimensions.iconXXL, color: AppColors.error),
                SizedBox(height: AppDimensions.spaceM),
                Text(
                  l10n.errorPrefix(state.message),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                ),
                SizedBox(height: AppDimensions.spaceM),
                ElevatedButton(
                  onPressed: () {
                    context.read<ForumBloc>().add(LoadForums(category));
                  },
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        // Initial state
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
