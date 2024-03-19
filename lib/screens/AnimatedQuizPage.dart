import 'package:flutter/material.dart';
import 'package:guardiancare/screens/quizQuestionsPage.dart'; // Assuming this is the correct import for the quiz questions page

class AnimatedQuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create a list of quizzes
    List<Quiz> quizzes = [
      // Add your quizzes here...
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Animated Quiz Page.'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
            quizzes.length,
                (index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: QuizTile(quiz: quizzes[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class QuizTile extends StatefulWidget {
  final Quiz quiz;

  const QuizTile({required this.quiz});

  @override
  _QuizTileState createState() => _QuizTileState();
}

class _QuizTileState extends State<QuizTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: GestureDetector(
        onTap: () {
          // Show title and description on tap
          _animationController.forward(from: 0.0);
        },
        onDoubleTap: () {
          // Navigate to the QuizQuestionsPage with the corresponding questions
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizQuestionsPage(
                questions: widget.quiz.questions,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: _animation.value,
              duration: Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.white.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          widget.quiz.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          widget.quiz.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _animationController.forward(from: 0.0);
              },
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    widget.quiz.imageUrl,
                    fit: BoxFit.cover,
                    height: 200,
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
