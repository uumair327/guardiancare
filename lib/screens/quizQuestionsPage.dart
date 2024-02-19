import 'package:flutter/material.dart';

class QuizQuestionsPage extends StatefulWidget {
  @override
  _QuizQuestionsPageState createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  int currentQuestionIndex = 0; // Index of the current question
  List<Map<String, dynamic>> questions = [
    {
      'question': 'Question 1',
      'options': ['Option A', 'Option B', 'Option C', 'Option D'],
      'correctAnswerIndex': 0,
    },
    {
      'question': 'Question 2',
      'options': ['Option A', 'Option B', 'Option C', 'Option D'],
      'correctAnswerIndex': 1,
    },
    {
      'question': 'Question 3',
      'options': ['Option A', 'Option B', 'Option C', 'Option D'],
      'correctAnswerIndex': 2,
    },
    {
      'question': 'Question 4',
      'options': ['Option A', 'Option B', 'Option C', 'Option D'],
      'correctAnswerIndex': 3,
    },
    {
      'question': 'Question 5',
      'options': ['Option A', 'Option B', 'Option C', 'Option D'],
      'correctAnswerIndex': 0,
    },
  ];

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
            SizedBox(height: 16),
            Text(
              questions[currentQuestionIndex]['question'],
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(
              questions[currentQuestionIndex]['options'].length,
              (index) => ElevatedButton(
                onPressed: () {
                  // Check if the selected option is correct
                  if (index ==
                      questions[currentQuestionIndex]['correctAnswerIndex']) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Correct!'),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Incorrect!'),
                    ));
                  }
                  // Move to the next question after a short delay
                  Future.delayed(Duration(seconds: 2), () {
                    setState(() {
                      if (currentQuestionIndex < questions.length - 1) {
                        currentQuestionIndex++;
                      } else {
                        // Show a dialog or navigate to the quiz result page if all questions are answered
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Quiz Completed'),
                              content: Text('You have completed the quiz!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    });
                  });
                },
                child: Text(questions[currentQuestionIndex]['options'][index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
