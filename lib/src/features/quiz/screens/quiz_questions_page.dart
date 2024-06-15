import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/quiz/common_widgets/quiz_question_widget.dart';
import 'package:guardiancare/src/features/quiz/controllers/quiz_controller.dart';
import 'package:guardiancare/src/gemini/processCategories.dart';

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
                // child: SingleChildScrollView(
                child: QuizQuestionWidget(
                  questionIndex: currentQuestionIndex + 1,
                  question: widget.questions[currentQuestionIndex],
                  onPressed: (int selectedOptionIndex) {
                    // Check if the selected option is correct
                    if (selectedOptionIndex ==
                        widget.questions[currentQuestionIndex]
                            ['correctAnswerIndex']) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Correct!'),
                      ));
                      setState(() {
                        correctAnswers++;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Incorrect!'),
                      ));
                      setState(() {
                        incorrectCategories.add(
                            widget.questions[currentQuestionIndex]['category']);
                      });
                    }
                    // Move to the next question after a short delay
                    Future.delayed(const Duration(seconds: 3), () {
                      setState(() {
                        if (currentQuestionIndex <
                            widget.questions.length - 1) {
                          currentQuestionIndex++;
                        } else {
                          if (incorrectCategories.isNotEmpty) {
                            Future<bool> processSuccess = processCategories(
                                incorrectCategories,
                                widget.questions[0]['quiz']);
                            print(processSuccess);
                          }

                          // Show quiz completed dialog
                          QuizController.showQuizCompletedDialog(
                              context, correctAnswers, widget.questions.length);
                        }
                      });
                    });
                  },
                ),
                // ),
              ),
            if (currentQuestionIndex >= widget.questions.length)
              const Center(
                child: Text(
                  'Quiz Completed!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(239, 72, 53, 1)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
