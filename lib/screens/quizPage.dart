import 'package:flutter/material.dart';

class QuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create a list of quizzes
    List<Quiz> quizzes = [
      Quiz(
        imageUrl: 'assets/images/quiz1.jpg',
        title: 'What is child abuse',
        description: 'This is a quiz on child abuse.',
        questions: [
          {
            'question': 'What is the most common form of child abuse?',
            'options': [
              'Physical abuse',
              'Emotional abuse',
              'Neglect',
              'Sexual abuse'
            ],
            'correctAnswerIndex': 2,
          },
          // Add more questions
          // ...
        ],
      ),
      // Add more quizzes
      // ...
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Page'),
      ),
      body: Container(
        color: Colors.green, // Background color for the whole page
        child: ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  // Navigate to the QuizQuestionsPage with the corresponding questions
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizQuestionsPage(
                        questions: quizzes[index].questions,
                      ),
                    ),
                  );
                },
                child: QuizTile(quiz: quizzes[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class QuizTile extends StatelessWidget {
  final Quiz quiz;

  const QuizTile({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              quiz.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors
                .white, // Background color for the quiz title and description
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  quiz.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white, // Text color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Quiz {
  final String imageUrl;
  final String title;
  final String description;
  final List<Map<String, dynamic>> questions;

  Quiz({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.questions,
  });
}

class QuizQuestionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  QuizQuestionsPage({required this.questions});

  @override
  _QuizQuestionsPageState createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  int currentQuestionIndex = 0; // Index of the current question
  int correctAnswers = 0; // Number of correct answers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Questions'),
      ),
      body: Container(
        color: Colors.green, // Background color for the whole page
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1}',
                    style: const TextStyle(
                      fontSize: 24, // Larger font size for question
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.questions[currentQuestionIndex]['question'],
                    textAlign: TextAlign.center, // Align center
                    style: const TextStyle(
                      fontSize: 20, // Larger font size for question
                      color: Colors.white, // Text color
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              widget.questions[currentQuestionIndex]['options'].length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side:
                          const BorderSide(color: Colors.white), // White border
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    backgroundColor: Colors.green, // Green background color
                  ),
                  onPressed: () {
                    // Check if the selected option is correct
                    if (index ==
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
                    }
                    // Move to the next question after a short delay
                    Future.delayed(const Duration(seconds: 2), () {
                      setState(() {
                        if (currentQuestionIndex <
                            widget.questions.length - 1) {
                          currentQuestionIndex++;
                        } else {
                          // Show a dialog with the score
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Quiz Completed'),
                                content: Text(
                                    'You have completed the quiz!\n\nYour score: $correctAnswers/${widget.questions.length}'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.popUntil(
                                          context, ModalRoute.withName('/'));
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      });
                    });
                  },
                  child: Text(
                    widget.questions[currentQuestionIndex]['options'][index],
                    style: const TextStyle(color: Colors.white), // Text color
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
