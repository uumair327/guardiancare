import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/features/quiz/services/recommendation_service.dart';

class QuizQuestionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const QuizQuestionsPage({Key? key, required this.questions}) : super(key: key);

  @override
  State<QuizQuestionsPage> createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int? selectedOption;
  bool showFeedback = false;

  @override
  Widget build(BuildContext context) {
    final isLastQuestion = currentQuestionIndex >= widget.questions.length - 1;
    final question = currentQuestionIndex < widget.questions.length
        ? widget.questions[currentQuestionIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Questions'),
        backgroundColor: tPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: question == null
          ? _buildCompletionScreen()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / widget.questions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(tPrimaryColor),
                  ),
                  const SizedBox(height: 16),
                  
                  // Question number
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${widget.questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Question text
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        question['question'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: (question['options'] as List?)?.length ?? 0,
                      itemBuilder: (context, index) {
                        final option = question['options'][index];
                        final isSelected = selectedOption == index;
                        final correctIndex = question['correctAnswerIndex'];
                        final isCorrect = index == correctIndex;
                        
                        Color? cardColor;
                        if (showFeedback) {
                          if (isCorrect) {
                            cardColor = Colors.green[100];
                          } else if (isSelected) {
                            cardColor = Colors.red[100];
                          }
                        } else if (isSelected) {
                          cardColor = tPrimaryColor.withOpacity(0.1);
                        }
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: cardColor,
                          child: ListTile(
                            title: Text(option),
                            leading: Radio<int>(
                              value: index,
                              groupValue: selectedOption,
                              onChanged: showFeedback
                                  ? null
                                  : (value) {
                                      setState(() {
                                        selectedOption = value;
                                      });
                                    },
                            ),
                            trailing: showFeedback
                                ? Icon(
                                    isCorrect ? Icons.check_circle : (isSelected ? Icons.cancel : null),
                                    color: isCorrect ? Colors.green : Colors.red,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentQuestionIndex > 0)
                        ElevatedButton(
                          onPressed: showFeedback ? null : _goToPreviousQuestion,
                          child: const Text('Previous'),
                        )
                      else
                        const SizedBox.shrink(),
                      
                      ElevatedButton(
                        onPressed: selectedOption == null
                            ? null
                            : showFeedback
                                ? _goToNextQuestion
                                : _submitAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tPrimaryColor,
                        ),
                        child: Text(
                          showFeedback
                              ? (isLastQuestion ? 'Finish' : 'Next')
                              : 'Submit',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _submitAnswer() {
    if (selectedOption == null) return;
    
    final correctIndex = widget.questions[currentQuestionIndex]['correctAnswerIndex'];
    if (selectedOption == correctIndex) {
      setState(() {
        correctAnswers++;
      });
    }
    
    setState(() {
      showFeedback = true;
    });
  }

  void _goToPreviousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        selectedOption = null;
        showFeedback = false;
      }
    });
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
        showFeedback = false;
      });
    } else {
      // Process quiz completion and generate recommendations
      _processQuizCompletion();
      
      // Show completion
      setState(() {
        currentQuestionIndex = widget.questions.length;
      });
    }
  }

  Future<void> _processQuizCompletion() async {
    print('=== QUIZ COMPLETION STARTED ===');
    
    // Collect all categories from questions
    final categories = <String>{};
    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      print('Question $i category: ${question['category']}');
      if (question['category'] != null && question['category'].toString().isNotEmpty) {
        categories.add(question['category'].toString());
      }
    }

    print('Collected categories: $categories');

    // If no categories found, use quiz name as category
    if (categories.isEmpty && widget.questions.isNotEmpty) {
      final quizName = widget.questions[0]['quiz'];
      if (quizName != null && quizName.toString().isNotEmpty) {
        categories.add(quizName.toString());
        print('No categories found, using quiz name as category: $quizName');
      }
    }

    // If still no categories, use default
    if (categories.isEmpty) {
      categories.addAll(['child safety', 'parenting tips']);
      print('No categories or quiz name found, using defaults: $categories');
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('User UID: ${user.uid}');
        
        // Save quiz completion to Firestore
        await FirebaseFirestore.instance.collection('quiz_results').add({
          'uid': user.uid,
          'quizName': widget.questions.isNotEmpty ? widget.questions[0]['quiz'] : 'Unknown',
          'score': correctAnswers,
          'totalQuestions': widget.questions.length,
          'categories': categories.toList(),
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Quiz result saved to Firestore');
        
        // Generate recommendations based on quiz categories
        print('Calling RecommendationService.generateRecommendations with: ${categories.toList()}');
        await RecommendationService.generateRecommendations(categories.toList());
        
        print('=== QUIZ COMPLETION FINISHED ===');
      } else {
        print('ERROR: No user logged in!');
      }
    } catch (e) {
      print('ERROR in _processQuizCompletion: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Widget _buildCompletionScreen() {
    final percentage = (correctAnswers / widget.questions.length * 100).round();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: tPrimaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quiz Completed!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: tPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You scored $correctAnswers out of ${widget.questions.length}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: tPrimaryColor,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: tPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Back to Quizzes',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
