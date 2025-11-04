import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import 'categories_grid.dart';
import 'videos_grid.dart';
import 'package:guardiancare/src/constants/colors.dart';

class LearnView extends StatelessWidget {
  const LearnView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearnBloc, LearnState>(
      builder: (context, state) {
        if (state is LearnLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading categories...'),
              ],
            ),
          );
        }

        if (state is CategoriesLoaded) {
          return CategoriesGrid(categories: state.categories);
        }

        if (state is VideosLoading) {
          return Column(
            children: [
              _buildBackHeader(context, state.categoryName),
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading videos...'),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        if (state is VideosLoaded) {
          return Column(
            children: [
              _buildBackHeader(context, state.categoryName),
              Expanded(
                child: VideosGrid(
                  videos: state.videos,
                  categoryName: state.categoryName,
                ),
              ),
            ],
          );
        }

        if (state is LearnError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<LearnBloc>().add(RetryRequested());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tPrimaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildBackHeader(BuildContext context, String categoryName) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<LearnBloc>().add(BackToCategories());
            },
          ),
          Expanded(
            child: Text(
              categoryName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: tPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}