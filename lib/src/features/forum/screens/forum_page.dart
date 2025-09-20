import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/forum/forum.dart';
import 'package:guardiancare/src/features/forum/screens/add_forum_screen.dart';
import 'package:guardiancare/src/features/forum/widgets/forum_widget.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  @override
  void initState() {
    super.initState();
    // Load forums when page initializes
    context.read<ForumBloc>().add(const ForumLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ForumBloc>().add(const ForumRefreshRequested());
        },
        child: BlocListener<ForumBloc, ForumState>(
          listener: (context, state) {
            if (state is ForumAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Forum added successfully!')),
              );
            } else if (state is ForumError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<ForumBloc, ForumState>(
            builder: (context, state) {
              if (state is ForumLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ForumLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: state.forums.length,
                  itemBuilder: (context, index) {
                    return ForumWidget(forum: state.forums[index]);
                  },
                );
              } else if (state is ForumEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No forums available.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Be the first to start a discussion!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              } else if (state is ForumError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ForumBloc>().add(const ForumLoadRequested());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              // Default case
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(-5, -50),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddForumScreen()),
            );
          },
          backgroundColor: tPrimaryColor,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: tWhiteColor,
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
