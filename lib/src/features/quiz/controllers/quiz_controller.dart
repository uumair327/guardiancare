import 'package:flutter/material.dart';

class QuizController {
  static Future<void> showQuizCompletedDialog(BuildContext context, int correctAnswers, int totalQuestions) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Completed'),
          content: Text(
            'You have completed the quiz!\n\nYour score: $correctAnswers/$totalQuestions',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
