import 'package:flutter/material.dart';
import 'Add_Forum/add_forum_Screen.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Safety Laws Forum'),
      ),
      body: Center(
       child: Text('Child Safety Laws Forum'),
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
