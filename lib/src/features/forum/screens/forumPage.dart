import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardianscare/src/constants/colors.dart';
import 'package:guardianscare/src/features/forum/common_widgets/forum_widget.dart';
import 'package:guardianscare/src/features/forum/models/Forum.dart';
import 'package:guardianscare/src/features/forum/screens/add_forum_Screen.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Child Safety Laws Forum'),
      // ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('forum').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.docs;
            List<Forum> forumList = [];
            for (var element in data) {
              Forum forum = Forum.fromMap(element.data());
              forumList.add(forum);
            }
            return ListView(
              padding: const EdgeInsets.all(10),
              children: [
                for (var forum in forumList) ForumWidget(forum: forum),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(-5, -12),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddForumScreen()));
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
