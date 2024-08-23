import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/explore/screens/explore_screen.dart';

class QuizController {
  static Future<void> showQuizCompletedDialog(BuildContext context,
      int correctAnswers, int totalQuestions, int incorrect) async {
    String message;
    Widget content;

    if (incorrect == 0) {
      // All answers are correct
      message =
          'Congratulations! You have completed all the questions.\n\nScore: $correctAnswers/$totalQuestions.\n\nKeep on learning! ✨';
      content = Text(message);
    } else {
      // Some answers are incorrect
      message =
          'Thanks for completing the quiz!\n\nScore: $correctAnswers/$totalQuestions.\n\nVisit ';
      content = RichText(
        text: TextSpan(
          text: message,
          style: const TextStyle(color: Colors.black),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () async {
                  await Future.delayed(const Duration(seconds: 2));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Explore()),
                  );
                },
                child: const Text(
                  'Recommended',
                  style: TextStyle(
                      color: tPrimaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const TextSpan(
              text: ' section to boost your score next time. 😇',
            ),
          ],
        ),
      );
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Quiz Completed',
            style: TextStyle(fontWeight: FontWeight.bold, color: tPrimaryColor),
          ),
          content: content,
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
