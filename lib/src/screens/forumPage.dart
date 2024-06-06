import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/Forum.dart';
import 'Add_Forum/add_forum_Screen.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Safety Laws Forum'),
      ),
      body:  StreamBuilder(
        stream: FirebaseFirestore.instance.collection('forum').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if(snapshot.hasData && snapshot.data!=null) {
          final data = snapshot.data!.docs;
          List<Forum> forumList = [];
          for (var element in data){
            Forum forum = Forum.fromMap(element.data());
            forumList.add(forum);
          }
          return ListView(
            children:[
              for (var forum in forumList)
                ListTile (
                  title: Text(forum.title),
                  subtitle: Text(forum.description),
                )
            ],
          );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddForumScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
