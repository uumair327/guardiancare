import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/di/injection_container.dart' as di;
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_bloc.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_event.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_state.dart';
import 'package:guardiancare/features/forum/presentation/widgets/forum_list_item.dart';
import 'package:guardiancare/core/l10n/generated/app_localizations.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocProvider(
      create: (context) => di.sl<ForumBloc>()..add(const LoadForums(ForumCategory.parent)),
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
              body: const TabBarView(
                children: [
                  _ForumListView(category: ForumCategory.parent),
                  _ForumListView(category: ForumCategory.children),
                ],
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
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
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
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noForumsAvailable,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noCommentsYet,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ForumBloc>().add(RefreshForums(category));
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: state.forums.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  l10n.errorPrefix(state.message),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
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
