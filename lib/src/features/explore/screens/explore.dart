import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/core/di/dependency_injection.dart';
import 'package:guardiancare/src/common_widgets/video_player_page.dart';
import 'package:guardiancare/src/features/quiz/screens/quiz_page.dart';
import '../bloc/explore_bloc.dart';
import '../bloc/explore_event.dart';
import '../bloc/explore_state.dart';

class Explore extends StatelessWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final user = FirebaseAuth.instance.currentUser;
        final bloc = DependencyInjection.get<ExploreBloc>();
        if (user != null) {
          bloc.add(RecommendedContentRequested(user.uid));
        }
        return bloc;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              DefaultTabController(
                length: 1,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Recommended'),
                      ],
                      indicatorColor: tPrimaryColor,
                      labelColor: tPrimaryColor,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.73,
                      child: const TabBarView(
                        children: [
                          _RecommendedContent(),
                        ],
                      ),
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

class _RecommendedContent extends StatelessWidget {
  const _RecommendedContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        if (state is ExploreLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RecommendedContentLoaded) {
          if (state.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildContentList(context, state.content);
        } else if (state is ExploreError) {
          return _buildErrorState(context, state.message);
        }
        
        // Check if user is logged in
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return const Center(child: Text('User not logged in'));
        }
        
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'No Recommended Content Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Take a quick quiz to get personalized content recommendations!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await Future.delayed(const Duration(seconds: 2));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuizPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: tPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Go to Quiz Page',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on your quiz score, we will provide personalized recommendations.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentList(BuildContext context, content) {
    return ListView.builder(
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerPage(videoUrl: item.videoUrl),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.network(
                  item.thumbnail,
                  fit: BoxFit.cover,
                  height: 200,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $message',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                context.read<ExploreBloc>().add(RecommendedContentRequested(user.uid));
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
