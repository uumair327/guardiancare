import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'dart:async';

class ReminderDialog extends StatelessWidget {
  final VoidCallback onAgree;

  const ReminderDialog({super.key, required this.onAgree});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Stay Safe Online'),
      content: const Text(
        'Please remember to be safe online and be aware of the real-world risks of online interactions before exchanging any media or information.',
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              onAgree();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: tPrimaryColor, // Text color
              backgroundColor: Colors.transparent, // Button background color
              padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            ),
            child: const Text(
              'I Understand',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ScreenTimeReminder {
  Timer? _reminderTimer;

  void startReminder(BuildContext context, Duration interval) {
    _reminderTimer = Timer.periodic(interval, (timer) {
      showDialog(
        context: context,
        builder: (context) => ReminderDialog(
          onAgree: () {
            // Handle user acknowledgment
          },
        ),
      );
    });
  }

  void stopReminder() {
    _reminderTimer?.cancel();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("GuardianCare")),
        body: const Center(child: ReminderHome()),
      ),
    );
  }
}

class ReminderHome extends StatefulWidget {
  const ReminderHome({super.key});

  @override
  _ReminderHomeState createState() => _ReminderHomeState();
}

class _ReminderHomeState extends State<ReminderHome> {
  final ScreenTimeReminder _screenTimeReminder = ScreenTimeReminder();

  @override
  void initState() {
    super.initState();
    // Start reminders at 25-minute intervals
    _screenTimeReminder.startReminder(context, const Duration(minutes: 25));
  }

  @override
  void dispose() {
    _screenTimeReminder.stopReminder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Text("Children's View - Stay Safe Online");
  }
}
