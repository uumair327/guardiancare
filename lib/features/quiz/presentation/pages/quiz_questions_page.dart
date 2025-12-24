import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/quiz/quiz.dart';

class QuizQuestionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const QuizQuestionsPage({super.key, required this.questions});

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

    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizQuestions),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SafeArea(
        child: question == null
          ? _buildCompletionScreen()
          : Padding(
              padding: EdgeInsets.all(AppDimensions.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / widget.questions.length,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: AppDimensions.spaceM),
                  
                  // Question number
                  Text(
                    l10n.questionOf(currentQuestionIndex + 1, widget.questions.length),
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceM),
                  
                  // Question text
                  Card(
                    elevation: AppDimensions.cardElevationLow,
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.cardPadding),
                      child: Text(
                        question['question'] ?? '',
                        style: AppTextStyles.h5,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceL),
                  
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
                            cardColor = AppColors.success.withOpacity(0.2);
                          } else if (isSelected) {
                            cardColor = AppColors.error.withOpacity(0.2);
                          }
                        } else if (isSelected) {
                          cardColor = AppColors.primary.withOpacity(0.1);
                        }
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: AppDimensions.spaceM),
                          color: cardColor,
                          child: ListTile(
                            title: Text(option, style: AppTextStyles.body1),
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
                                    color: isCorrect ? AppColors.success : AppColors.error,
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
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text(
                          showFeedback
                              ? (isLastQuestion ? l10n.finish : l10n.next)
                              : l10n.submit,
                          style: AppTextStyles.button,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
      _processQuizCompletion();
      setState(() {
        currentQuestionIndex = widget.questions.length;
      });
    }
  }

  Future<void> _processQuizCompletion() async {
    final categories = <String>{};
    for (final question in widget.questions) {
      final category = question['category'];
      if (category != null && category.toString().isNotEmpty) {
        categories.add(category.toString());
      }
    }

    if (categories.isEmpty && widget.questions.isNotEmpty) {
      final quizName = widget.questions[0]['quiz'];
      if (quizName != null && quizName.toString().isNotEmpty) {
        categories.add(quizName.toString());
      }
    }

    if (categories.isEmpty) {
      categories.addAll(['child safety', 'parenting tips']);
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final quizResultData = {
          'uid': user.uid,
          'quizName': widget.questions.isNotEmpty ? widget.questions[0]['quiz'] : 'Unknown',
          'score': correctAnswers,
          'totalQuestions': widget.questions.length,
          'categories': categories.toList(),
          'timestamp': FieldValue.serverTimestamp(),
        };
        
        await FirebaseFirestore.instance.collection('quiz_results').add(quizResultData);
        await RecommendationService.generateRecommendations(categories.toList());
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
      debugPrint('Error in quiz completion: $e');
    }
  }

  Widget _buildCompletionScreen() {
    final percentage = (correctAnswers / widget.questions.length * 100).round();
    final l10n = AppLocalizations.of(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: AppDimensions.iconXXL * 1.5,
              color: AppColors.primary,
            ),
            SizedBox(height: AppDimensions.spaceL),
            Text(
              l10n.quizCompleted,
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: AppDimensions.spaceM),
            Text(
              l10n.youScored(correctAnswers, widget.questions.length),
              style: AppTextStyles.h4,
            ),
            SizedBox(height: AppDimensions.spaceS),
            Text(
              '$percentage%',
              style: AppTextStyles.h1.copyWith(
                fontSize: 48,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.spaceL),
            Container(
              padding: EdgeInsets.all(AppDimensions.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary, size: AppDimensions.iconL),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    l10n.generatingRecommendations,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    l10n.checkExploreTab,
                    style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDimensions.spaceXL),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.buttonPaddingH,
                    vertical: AppDimensions.buttonPaddingV,
                  ),
                ),
                child: Text(l10n.backToQuizzes, style: AppTextStyles.button),
              ),
            ),
            SizedBox(height: AppDimensions.spaceM),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.buttonPaddingH,
                    vertical: AppDimensions.buttonPaddingV,
                  ),
                  side: BorderSide(color: AppColors.primary, width: AppDimensions.borderMedium),
                ),
                child: Text(
                  l10n.viewRecommendations,
                  style: AppTextStyles.button.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
