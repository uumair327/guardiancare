import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

 
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
        title: const Text('Add Blog'),
        actions: [
          IconButton(onPressed: (){},
           icon: const Icon(Icons.done))
        ]
      ),
      body: Form (
        key: _formKey,
        child : ListView(
        padding: const EdgeInsets.all(15),
        children:[
          TextFormField(
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
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter the Description of the Forum  post',
              border:OutlineInputBorder(),
            ),
            validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the title';
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

  }
}