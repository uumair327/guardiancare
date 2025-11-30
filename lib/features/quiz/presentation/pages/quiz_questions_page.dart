import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/features/quiz/services/recommendation_service.dart';
import 'package:guardiancare/core/l10n/generated/app_localizations.dart';

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

    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizQuestions),
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
                    l10n.questionOf(currentQuestionIndex + 1, widget.questions.length),
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
                          child: Text(l10n.previous),
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
                              ? (isLastQuestion ? l10n.finish : l10n.next)
                              : l10n.submit,
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
    print('\n╔════════════════════════════════════════╗');
    print('║   QUIZ COMPLETION PROCESS STARTED      ║');
    print('╚════════════════════════════════════════╝\n');
    
    print('📊 Quiz Stats:');
    print('   Total questions: ${widget.questions.length}');
    print('   Correct answers: $correctAnswers');
    print('   Score: ${(correctAnswers / widget.questions.length * 100).round()}%');
    
    // Collect all categories from questions
    final categories = <String>{};
    print('\n📂 Collecting categories from questions:');
    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final category = question['category'];
      print('   Question ${i + 1}: category = "$category"');
      if (category != null && category.toString().isNotEmpty) {
        categories.add(category.toString());
        print('      ✅ Added to set');
      } else {
        print('      ⏭️ Skipped (null or empty)');
      }
    }

    print('\n📋 Collected ${categories.length} unique categories: $categories');

    // If no categories found, use quiz name as category
    if (categories.isEmpty && widget.questions.isNotEmpty) {
      final quizName = widget.questions[0]['quiz'];
      print('\n⚠️ No categories found, checking quiz name...');
      print('   Quiz name: "$quizName"');
      if (quizName != null && quizName.toString().isNotEmpty) {
        categories.add(quizName.toString());
        print('   ✅ Using quiz name as category: $quizName');
      }
    }

    // If still no categories, use default
    if (categories.isEmpty) {
      print('\n⚠️ Still no categories, using defaults...');
      categories.addAll(['child safety', 'parenting tips']);
      print('   ✅ Using default categories: $categories');
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('\n👤 User Info:');
        print('   UID: ${user.uid}');
        print('   Email: ${user.email}');
        
        // Save quiz completion to Firestore
        print('\n💾 Saving quiz result to Firestore...');
        final quizResultData = {
          'uid': user.uid,
          'quizName': widget.questions.isNotEmpty ? widget.questions[0]['quiz'] : 'Unknown',
          'score': correctAnswers,
          'totalQuestions': widget.questions.length,
          'categories': categories.toList(),
          'timestamp': FieldValue.serverTimestamp(),
        };
        print('   Data: $quizResultData');
        
        final docRef = await FirebaseFirestore.instance.collection('quiz_results').add(quizResultData);
        print('   ✅ Quiz result saved with ID: ${docRef.id}');
        
        // Generate recommendations based on quiz categories
        print('\n🎯 Calling RecommendationService.generateRecommendations');
        print('   Categories: ${categories.toList()}');
        print('   Starting recommendation generation...\n');
        
        await RecommendationService.generateRecommendations(categories.toList());
        
        print('\n╔════════════════════════════════════════╗');
        print('║   QUIZ COMPLETION PROCESS FINISHED     ║');
        print('╚════════════════════════════════════════╝\n');
      } else {
        print('\n❌ ERROR: No user logged in!');
      }
    } catch (e, stackTrace) {
      print('\n❌ ERROR in _processQuizCompletion: $e');
      print('   Stack trace: $stackTrace');
    }
  }

  Widget _buildCompletionScreen() {
    final percentage = (correctAnswers / widget.questions.length * 100).round();
    final l10n = AppLocalizations.of(context)!;
    
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
            Text(
              l10n.quizCompleted,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: tPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.youScored(correctAnswers, widget.questions.length),
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
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome, color: tPrimaryColor, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    l10n.generatingRecommendations,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: tPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.checkExploreTab,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
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
              child: Text(
                l10n.backToQuizzes,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // Navigate to explore page to see recommendations
                Navigator.pop(context); // Go back to quiz page
                // The user can then navigate to Explore tab
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                side: const BorderSide(color: tPrimaryColor, width: 2),
              ),
              child: Text(
                l10n.viewRecommendations,
                style: const TextStyle(fontSize: 18, color: tPrimaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
