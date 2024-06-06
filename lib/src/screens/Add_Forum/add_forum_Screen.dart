import 'package:flutter/material.dart';
 
class AddForumScreen extends StatefulWidget {
  const AddForumScreen ({super.key});
  @override
  State<AddForumScreen> createState()=> _AddForumScreenState();
 
}
class _AddForumScreenState extends State<AddForumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blog'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Add functionality to save the blog post
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}