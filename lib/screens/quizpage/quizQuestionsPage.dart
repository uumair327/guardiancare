import 'package:flutter/material.dart';

class QuizQuestionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  QuizQuestionsPage({required this.questions});

  @override
  _QuizQuestionsPageState createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Questions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.questions[currentQuestionIndex]['question'],
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(
              widget.questions[currentQuestionIndex]['options'].length,
                  (index) => ElevatedButton(
                onPressed: () {
                  bool isCorrect = index ==
                      widget.questions[currentQuestionIndex]['correctAnswerIndex'];
                  showFeedbackSnackBar(isCorrect);
                  if (isCorrect) {
                    correctAnswers++;
                  }
                  Future.delayed(Duration(seconds: 2), () {
                    setState(() {
                      if (currentQuestionIndex < widget.questions.length - 1) {
                        currentQuestionIndex++;
                      } else {
                        showQuizCompletedDialog();
                      }
                    });
                  });
                },
                child: Text(
                  widget.questions[currentQuestionIndex]['options'][index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showFeedbackSnackBar(bool isCorrect) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text(
        isCorrect ? 'Correct!' :
        'Incorrect!',
          style: TextStyle(color: Colors.white),
        ),
          backgroundColor: isCorrect ? Colors.green : Colors.red,
        ),
    );
  }

  void showQuizCompletedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Completed'),
          content: Text(
              'You have completed the quiz!\n\nYour score: $correctAnswers/${widget.questions.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}