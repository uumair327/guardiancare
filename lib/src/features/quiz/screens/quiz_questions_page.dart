import 'package:flutter/material.dart';
import 'package:guardiancare/src/api/gemini/process_categories.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/quiz/common_widgets/quiz_question_widget.dart';
import 'package:guardiancare/src/features/quiz/controllers/quiz_controller.dart';

class QuizQuestionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  QuizQuestionsPage({required this.questions});

  @override
  _QuizQuestionsPageState createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  int currentQuestionIndex = 0; // Index of the current question
  int correctAnswers = 0; // Number of correct answers
  List<String> incorrectCategories = [];
  bool isBlocked = false; // Flag to block next actions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Questions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (currentQuestionIndex < widget.questions.length)
              Expanded(
                child: QuizQuestionWidget(
                  questionIndex: currentQuestionIndex + 1,
                  correctAnswerIndex: widget.questions[currentQuestionIndex]
                      ['correctAnswerIndex'],
                  question: widget.questions[currentQuestionIndex],
                  onPressed: (int selectedOptionIndex) {
                    // Check if the selected option is correct
                    if (selectedOptionIndex ==
                        widget.questions[currentQuestionIndex]
                            ['correctAnswerIndex']) {
                      setState(() {
                        correctAnswers++;
                      });
                    } else {
                      setState(() {
                        incorrectCategories.add(
                            widget.questions[currentQuestionIndex]['category']);
                      });
                    }

                    // Block for 3 seconds
                    setState(() {
                      isBlocked = true;
                    });

                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        isBlocked = false;
                      });
                    });
                  },
                ),
              ),
            if (currentQuestionIndex >= widget.questions.length)
              const Center(
                child: Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(239, 72, 53, 1),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: isBlocked ? null : _goToPreviousQuestion,
                    child: const Text(
                      'Previous',
                      style: const TextStyle(
                        color: tPrimaryColor,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: isBlocked ? null : _goToNextQuestion,
                  child: Text(
                    currentQuestionIndex == widget.questions.length - 1
                        ? 'Finish'
                        : 'Next',
                    style: const TextStyle(
                      color: tPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreviousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      }
    });
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Process completion
      if (incorrectCategories.isNotEmpty) {
        Future<bool> processSuccess =
            processCategories(incorrectCategories, widget.questions[0]['quiz']);
        print(processSuccess);
      }

      // Show quiz completed dialog
      QuizController.showQuizCompletedDialog(
        context,
        correctAnswers,
        widget.questions.length,
        incorrectCategories.length,
      );
    }
  }
}
