import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/features/forum/forum.dart';
import 'package:guardiancare/src/features/forum/widgets/reminder_dialog.dart';

class AddForumScreen extends StatefulWidget {
  const AddForumScreen({super.key});

  @override
  State<AddForumScreen> createState() => _AddForumScreenState();
}

class _AddForumScreenState extends State<AddForumScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Forum Post'),
        actions: [
          IconButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _showReminderDialog();
              }
            },
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: BlocListener<ForumBloc, ForumState>(
        listener: (context, state) {
          if (state is ForumAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully added Forum Post')),
            );
            Navigator.pop(context);
          } else if (state is ForumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add Forum Post: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ForumBloc, ForumState>(
          builder: (context, state) {
            final isLoading = state is ForumAdding;
            
            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter the title of the Forum post',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter the Description of the Forum post',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the Description ';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showReminderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReminderDialog(
        onAgree: () {
          _submitForum();
        },
      ),
    );
  }

  void _submitForum() {
    context.read<ForumBloc>().add(
      ForumAddRequested(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
      ),
    );
  }
}
