import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/forum/controllers/forum_controller.dart';
import 'package:guardiancare/src/features/forum/models/forum.dart';
import 'package:guardiancare/src/features/forum/screens/add_forum_screen.dart';
import 'package:guardiancare/src/features/forum/widgets/forum_widget.dart';

class ForumPage extends StatelessWidget {
  final ForumController _forumController = ForumController();

  ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // You can uncomment and customize the AppBar if needed
      // appBar: AppBar(
      //   title: const Text('Child Safety Laws Forum'),
      // ),
      body: StreamBuilder<List<Forum>>(
        stream: _forumController.getForums(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final forumList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: forumList.length,
              itemBuilder: (context, index) {
                return ForumWidget(forum: forumList[index]);
              },
            );
          }
          return const Center(child: Text('No forums available.'));
        },
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
            color: Colors.white,
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
