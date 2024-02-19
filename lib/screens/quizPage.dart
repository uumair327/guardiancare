import 'package:flutter/material.dart';
import 'package:myapp/screens/quizQuestionsPage.dart';

class QuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create a list of quizzes
    List<Quiz> quizzes = [
      Quiz(
        imageUrl: 'assets/images/image.png',
        title: 'Quiz 1',
        description: 'This is a description of quiz 1.',
      ),
      Quiz(
        imageUrl: 'assets/images/image.png',
        title: 'Quiz 2',
        description: 'This is a description of quiz 2.',
      ),
      Quiz(
        imageUrl: 'assets/images/image.png',
        title: 'Quiz 3',
        description: 'This is a description of quiz 3.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Page'),
      ),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                // Navigate to the QuizQuestionsPage when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizQuestionsPage()),
                );
              },
              child: QuizTile(quiz: quizzes[index]),
            ),
          );
        },
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  quiz.description,
                  style: TextStyle(
                    fontSize: 16,
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

  Quiz({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}
