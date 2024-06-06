import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../models/Forum.dart';

 
class AddForumScreen extends StatefulWidget {
  const AddForumScreen ({super.key});
  @override
  State<AddForumScreen> createState()=> _AddForumScreenState();
}
class _AddForumScreenState extends State<AddForumScreen> {
  final  title = TextEditingController();
  final description = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Forum Post'),
        actions: [
          IconButton(onPressed: (){
            if(_formKey.currentState!.validate()){
              setState(() {
                loading = true;
              });
              addForum();
            } 
          },
           icon: const Icon(Icons.done),
           )
        ]
      ),
      body: loading? const Center (child:CircularProgressIndicator()):
      Form (
        key: _formKey,
        child : ListView(
        padding: const EdgeInsets.all(15),
        children:[
          TextFormField(
            controller: title,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter the title of the Forum  post',
              border: OutlineInputBorder(),
            ),
            validator : (value){
              if(value == null || value.isEmpty){
                return 'Please enter the title';
              }
              return null;
            }
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: description,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter the Description of the Forum  post',
              border:OutlineInputBorder(),
            ),
            validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Description ';
                  }
                  return null;
                }
          ),
        ],
      ),
      ),
    );
  }

  addForum() async{
    final db = FirebaseFirestore.instance.collection('forum');
    final user =FirebaseAuth.instance.currentUser!;
    final id=DateTime.now().microsecondsSinceEpoch.toString();
    Forum forum= Forum (
      id: id,
      userId: user.uid,
      title: title.text,
      description: description.text,
      createdAt: DateTime.now(),
    );
    try {
    await db.doc(id).set(forum.toMap());
    setState(() {
      loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully added Forum Post'),
        ),
      );
    }
    on FirebaseException catch(e){
      print(e);
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add Forum Post'),
        ),
      );
    }
   
  }
}