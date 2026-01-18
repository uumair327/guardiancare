import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:guardiancare/features/quiz/presentation/widgets/widgets.dart';

/// Quiz questions page with modern UI and animations
///
/// This page follows SRP by:
/// - Only rendering UI and dispatching events to QuizBloc
/// - Not containing business logic (scoring, Firestore access, recommendation calls)
class QuizQuestionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const QuizQuestionsPage({super.key, required this.questions});

  @override
  State<QuizQuestionsPage> createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage>
    with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int? selectedOption;
  bool showFeedback = false;
  bool isCompleted = false;

  late AnimationController _pageController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOut),
    );
    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = currentQuestionIndex < widget.questions.length
        ? widget.questions[currentQuestionIndex]
        : null;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          // Modern header
          QuizHeader(
            quizName: isCompleted ? UIStrings.quizComplete : null,
            currentQuestion: isCompleted ? null : currentQuestionIndex + 1,
            totalQuestions: isCompleted ? null : widget.questions.length,
            onBackPressed: () => Navigator.pop(context),
          ),
          // Content
          Expanded(
            child: isCompleted
                ? _buildCompletionScreen()
                : question != null
                    ? _buildQuestionContent(question)
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(Map<String, dynamic> question) {
    final isLastQuestion = currentQuestionIndex >= widget.questions.length - 1;
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            QuizProgressIndicator(
              currentQuestion: currentQuestionIndex + 1,
              totalQuestions: widget.questions.length,
            ),
            SizedBox(height: AppDimensions.spaceL),
            // Question card
            QuestionCard(
              question: question['question'] ?? '',
              questionNumber: currentQuestionIndex + 1,
              totalQuestions: widget.questions.length,
            ),
            SizedBox(height: AppDimensions.spaceL),
            // Options
            ..._buildOptions(question),
            SizedBox(height: AppDimensions.spaceXL),
            // Navigation buttons
            _buildNavigationButtons(isLastQuestion, l10n),
            SizedBox(height: AppDimensions.spaceL),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(Map<String, dynamic> question) {
    final options = question['options'] as List? ?? [];
    final correctIndex = question['correctAnswerIndex'];

    return List.generate(options.length, (index) {
      final delay = Duration(milliseconds: 100 + (index * 50));
      return Padding(
        padding: EdgeInsets.only(bottom: AppDimensions.spaceM),
        child: FadeSlideWidget(
          delay: delay,
          child: OptionCard(
            option: options[index],
            index: index,
            isSelected: selectedOption == index,
            showFeedback: showFeedback,
            isCorrect: index == correctIndex,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                selectedOption = index;
              });
            },
          ),
        ),
      );
    });
  }

  Widget _buildNavigationButtons(bool isLastQuestion, AppLocalizations l10n) {
    return Row(
      children: [
        // Previous button
        if (currentQuestionIndex > 0 && !showFeedback)
          Expanded(
            child: ScaleTapWidget(
              onTap: _goToPreviousQuestion,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colors.primary,
                    width: 2,
                  ),
                  borderRadius: AppDimensions.borderRadiusM,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        color: context.colors.primary,
                        size: AppDimensions.iconS,
                      ),
                      SizedBox(width: AppDimensions.spaceS),
                      Text(
                        l10n.previous,
                        style: AppTextStyles.button.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (currentQuestionIndex > 0 && !showFeedback)
          SizedBox(width: AppDimensions.spaceM),
        // Submit/Next button
        Expanded(
          flex: currentQuestionIndex > 0 && !showFeedback ? 1 : 2,
          child: AnimatedOpacity(
            duration: AppDurations.animationShort,
            opacity: selectedOption == null ? 0.5 : 1.0,
            child: ScaleTapWidget(
              onTap: selectedOption == null
                  ? null
                  : showFeedback
                      ? _goToNextQuestion
                      : _submitAnswer,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary,
                      context.colors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: AppDimensions.borderRadiusM,
                  boxShadow: selectedOption != null
                      ? [
                          BoxShadow(
                            color:
                                context.colors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showFeedback
                            ? (isLastQuestion ? l10n.finish : l10n.next)
                            : l10n.submit,
                        style: AppTextStyles.button,
                      ),
                      SizedBox(width: AppDimensions.spaceS),
                      Icon(
                        showFeedback
                            ? (isLastQuestion
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded)
                            : Icons.send_rounded,
                        color: AppColors.white,
                        size: AppDimensions.iconS,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitAnswer() {
    if (selectedOption == null) return;

    final correctIndex =
        widget.questions[currentQuestionIndex]['correctAnswerIndex'];

    // Dispatch event to QuizBloc for validation
    context.read<QuizBloc>().add(SubmitAnswerRequested(
          questionIndex: currentQuestionIndex,
          selectedOption: selectedOption!,
          correctAnswerIndex: correctIndex,
        ));

    // Update local state for UI feedback
    if (selectedOption == correctIndex) {
      HapticFeedback.mediumImpact();
      setState(() {
        correctAnswers++;
      });
    } else {
      HapticFeedback.heavyImpact();
    }

    setState(() {
      showFeedback = true;
    });
  }

  void _goToPreviousQuestion() {
    HapticFeedback.selectionClick();
    _pageController.reverse().then((_) {
      setState(() {
        if (currentQuestionIndex > 0) {
          currentQuestionIndex--;
          selectedOption = null;
          showFeedback = false;
        }
      });
      _pageController.forward();
    });
  }

  void _goToNextQuestion() {
    HapticFeedback.selectionClick();
    if (currentQuestionIndex < widget.questions.length - 1) {
      _pageController.reverse().then((_) {
        setState(() {
          currentQuestionIndex++;
          selectedOption = null;
          showFeedback = false;
        });
        _pageController.forward();
      });
    } else {
      _processQuizCompletion();
      setState(() {
        isCompleted = true;
      });
    }
  }

  void _processQuizCompletion() {
    context.read<QuizBloc>().add(CompleteQuizRequested(
          questions: widget.questions,
          correctAnswers: correctAnswers,
          totalQuestions: widget.questions.length,
        ));
  }

  Widget _buildCompletionScreen() {
    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Column(
            children: [
              SizedBox(height: AppDimensions.spaceL),
              // Result card
              ResultCard(
                correctAnswers: correctAnswers,
                totalQuestions: widget.questions.length,
                onBack: () => Navigator.pop(context),
              ),
              SizedBox(height: AppDimensions.spaceL),
              // Recommendations status
              _buildRecommendationsStatus(state),
              SizedBox(height: AppDimensions.spaceL),
            ],
          ),
        );
      },
    );
  }

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
        iconColor = context.colors.primary;
        break;
      case RecommendationsStatus.generated:
        icon = Icons.check_circle;
        title = l10n.generatingRecommendations;
        subtitle = l10n.checkExploreTab;
        iconColor = context.colors.success;
        break;
      case RecommendationsStatus.failed:
        icon = Icons.error_outline;
        title = l10n.generatingRecommendations;
        subtitle = state.error ?? l10n.checkExploreTab;
        iconColor = context.colors.error;
        break;
      case RecommendationsStatus.idle:
        icon = Icons.auto_awesome;
        title = l10n.generatingRecommendations;
        subtitle = l10n.checkExploreTab;
        iconColor = context.colors.primary;
    }

    return FadeSlideWidget(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.spaceL),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppDimensions.borderRadiusL,
          border: Border.all(
            color: iconColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spaceM),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: state.recommendationsStatus ==
                      RecommendationsStatus.generating
                  ? SizedBox(
                      width: AppDimensions.iconM,
                      height: AppDimensions.iconM,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: iconColor,
                      ),
                    )
                  : Icon(icon, color: iconColor, size: AppDimensions.iconM),
            ),
            SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
