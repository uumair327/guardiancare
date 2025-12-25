import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_state.dart';

/// Quiz questions page that displays questions and handles user interactions
/// 
/// This page follows SRP by:
/// - Only rendering UI and dispatching events to QuizBloc
/// - Not containing business logic (scoring, Firestore access, recommendation calls)
/// 
/// Requirements: 2.1, 2.2, 2.3, 2.4, 2.5
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
                            cardColor = AppColors.success.withValues(alpha: 0.2);
                          } else if (isSelected) {
                            cardColor = AppColors.error.withValues(alpha: 0.2);
                          }
                        } else if (isSelected) {
                          cardColor = AppColors.primary.withValues(alpha: 0.1);
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

  /// Submits the answer by dispatching event to QuizBloc
  /// Requirements: 2.1 - QuizBloc handles validation and scoring logic
  void _submitAnswer() {
    if (selectedOption == null) return;
    
    final correctIndex = widget.questions[currentQuestionIndex]['correctAnswerIndex'];
    
    // Dispatch event to QuizBloc for validation
    // Requirements: 2.1 - QuizBloc handles validation logic
    context.read<QuizBloc>().add(SubmitAnswerRequested(
      questionIndex: currentQuestionIndex,
      selectedOption: selectedOption!,
      correctAnswerIndex: correctIndex,
    ));
    
    // Update local state for UI feedback
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

  /// Processes quiz completion by dispatching event to QuizBloc
  /// Requirements: 2.2, 2.3 - QuizBloc handles repository coordination and recommendation generation
  void _processQuizCompletion() {
    // Dispatch event to QuizBloc for completion processing
    // Requirements: 2.2 - QuizBloc coordinates with Repository to persist results
    // Requirements: 2.3 - QuizBloc delegates to RecommendationUseCase
    context.read<QuizBloc>().add(CompleteQuizRequested(
      questions: widget.questions,
      correctAnswers: correctAnswers,
      totalQuestions: widget.questions.length,
    ));
  }

  Widget _buildCompletionScreen() {
    final percentage = (correctAnswers / widget.questions.length * 100).round();
    final l10n = AppLocalizations.of(context);
    
    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
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
                _buildRecommendationsStatus(state),
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
      },
    );
  }

  /// Builds the recommendations status widget based on BLoC state
  Widget _buildRecommendationsStatus(QuizState state) {
    final l10n = AppLocalizations.of(context);
    
    IconData icon;
    String title;
    String subtitle;
    Color iconColor;
    
    switch (state.recommendationsStatus) {
      case RecommendationsStatus.generating:
        icon = Icons.auto_awesome;
        title = l10n.generatingRecommendations;
        subtitle = l10n.checkExploreTab;
        iconColor = AppColors.primary;
        break;
      case RecommendationsStatus.generated:
        icon = Icons.check_circle;
        title = l10n.generatingRecommendations;
        subtitle = l10n.checkExploreTab;
        iconColor = AppColors.success;
        break;
      case RecommendationsStatus.failed:
        icon = Icons.error_outline;
        title = l10n.generatingRecommendations;
        subtitle = state.error ?? l10n.checkExploreTab;
        iconColor = AppColors.error;
        break;
      case RecommendationsStatus.idle:
        icon = Icons.auto_awesome;
        title = l10n.generatingRecommendations;
        subtitle = l10n.checkExploreTab;
        iconColor = AppColors.primary;
    }
    
    return Container(
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        children: [
          if (state.recommendationsStatus == RecommendationsStatus.generating)
            const CircularProgressIndicator()
          else
            Icon(icon, color: iconColor, size: AppDimensions.iconL),
          SizedBox(height: AppDimensions.spaceS),
          Text(
            title,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceXS),
          Text(
            subtitle,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
