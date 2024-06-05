import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';

class QuizQuestionWidget extends StatelessWidget {
  final int questionIndex;
  final Map<String, dynamic> question;
  final Function(int) onPressed;

  const QuizQuestionWidget({
    Key? key,
    required this.questionIndex,
    required this.question,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white, // Background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question $questionIndex',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: tTextPrimary, // Text color
              ),
            ),
            const SizedBox(height: 16),
            Text(
              question['question'],
              style: const TextStyle(
                fontSize: 20,
                color: tTextPrimary, // Text color
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              question['options'].length,
              (index) => SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () => onPressed(index),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                            color: tPrimaryColor), // White border
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: tTextPrimary,
                      elevation: 0, // Green background color
                    ),
                    child: Text(
                      question['options'][index],
                      style:
                          const TextStyle(color: tPrimaryColor), // Text color
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
