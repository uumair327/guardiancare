import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/api/gemini/process_categories.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/quiz/bloc/quiz_bloc.dart';
import 'package:guardiancare/src/features/quiz/common_widgets/quiz_question_widget.dart';
import 'package:guardiancare/src/features/quiz/controllers/quiz_controller.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_validation_service.dart';
import 'package:guardiancare/src/core/logging/app_logger.dart';

class QuizQuestionsPageBloc extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const QuizQuestionsPageBloc({Key? key, required this.questions}) : super(key: key);

  @override
  _QuizQuestionsPageBlocState createState() => _QuizQuestionsPageBlocState();
}

class _QuizQuestionsPageBlocState extends State<QuizQuestionsPageBloc> {
  bool isBlocked = false; // Flag to block next actions during feedback

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizBloc(),
      child: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          // Handle quiz completion
          if (state.quizCompleted) {
            _handleQuizCompletion(context, state);
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () => _onWillPop(context, state),
            child: Scaffold(
              appBar: AppBar(
                title: Text('Quiz Questions (${state.currentQuestionIndex + 1}/${widget.questions.length})'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '${(_getProgress(state) * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress bar
                    LinearProgressIndicator(
                      value: _getProgress(state),
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(tPrimaryColor),
                    ),
                    const SizedBox(height: 8),
                    // Question navigation dots
                    _buildQuestionNavigationDots(context, state),
                    const SizedBox(height: 16),
                    if (state.currentQuestionIndex < widget.questions.length)
                      Expanded(
                        child: _buildQuestionWidget(context, state),
                      ),
                    if (state.currentQuestionIndex >= widget.questions.length)
                      const Center(
                        child: Text(
                          'Quiz Completed!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(239, 72, 53, 1),
                          ),
                        ),
                      ),
                    _buildNavigationButtons(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionWidget(BuildContext context, QuizState state) {
    final bloc = context.read<QuizBloc>();
    final currentIndex = state.currentQuestionIndex;
    
    return QuizQuestionWidget(
      questionIndex: currentIndex,
      correctAnswerIndex: widget.questions[currentIndex]['correctAnswerIndex'],
      question: widget.questions[currentIndex],
      stateManager: null, // We'll need to update QuizQuestionWidget to work with BLoC
      onAnswerSelected: (int selectedOptionIndex, bool isCorrect) {
        final options = widget.questions[currentIndex]['options'] as List<String>;
        final selectedAnswer = options[selectedOptionIndex];
        
        // Dispatch answer selected event
        bloc.add(AnswerSelected(currentIndex, selectedAnswer));
        
        AppLogger.bloc('QuizBloc', 'AnswerSelected', state: 'Question $currentIndex: $selectedAnswer');
        
        // Block navigation temporarily for feedback display
        setState(() {
          isBlocked = true;
        });

        // Mark feedback as shown after delay
        Future.delayed(const Duration(seconds: 2), () {
          bloc.add(FeedbackShown(currentIndex));
          if (mounted) {
            setState(() {
              isBlocked = false;
            });
          }
        });
      },
    );
  }

  Widget _buildNavigationButtons(BuildContext context, QuizState state) {
    final bloc = context.read<QuizBloc>();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (state.currentQuestionIndex > 0)
          ElevatedButton(
            onPressed: _canGoToPrevious(state) ? () => bloc.add(const PreviousQuestion()) : null,
            child: const Text(
              'Previous',
              style: TextStyle(color: tPrimaryColor),
            ),
          ),
        ElevatedButton(
          onPressed: _canGoToNext(state) ? () => _goToNextQuestion(context, state) : null,
          child: Text(
            state.currentQuestionIndex == widget.questions.length - 1 ? 'Finish' : 'Next',
            style: const TextStyle(color: tPrimaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionNavigationDots(BuildContext context, QuizState state) {
    final bloc = context.read<QuizBloc>();
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final isAnswered = state.selectedAnswers.containsKey(index);
          final isCurrent = index == state.currentQuestionIndex;
          final isLocked = state.lockedQuestions[index] == true;
          
          Color dotColor;
          if (isCurrent) {
            dotColor = tPrimaryColor;
          } else if (isAnswered && isLocked) {
            final selectedAnswer = state.selectedAnswers[index];
            final correctAnswerIndex = widget.questions[index]['correctAnswerIndex'];
            final options = widget.questions[index]['options'] as List<String>;
            final correctAnswer = options[correctAnswerIndex];
            dotColor = selectedAnswer == correctAnswer ? Colors.green : Colors.red;
          } else if (isAnswered) {
            dotColor = Colors.orange;
          } else {
            dotColor = Colors.grey[400]!;
          }

          return GestureDetector(
            onTap: () => _navigateToQuestion(context, index, state),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _getProgress(QuizState state) {
    if (widget.questions.isEmpty) return 0.0;
    return state.selectedAnswers.length / widget.questions.length;
  }

  bool _canGoToPrevious(QuizState state) {
    return !isBlocked && state.currentQuestionIndex > 0;
  }

  bool _canGoToNext(QuizState state) {
    if (isBlocked) return false;
    
    final currentIndex = state.currentQuestionIndex;
    if (currentIndex == widget.questions.length - 1) {
      return state.selectedAnswers.containsKey(currentIndex);
    }
    
    return state.selectedAnswers.containsKey(currentIndex);
  }

  void _goToNextQuestion(BuildContext context, QuizState state) {
    final bloc = context.read<QuizBloc>();
    final currentIndex = state.currentQuestionIndex;
    
    if (!_canGoToNext(state)) {
      if (!state.selectedAnswers.containsKey(currentIndex)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please answer the current question first.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (currentIndex < widget.questions.length - 1) {
      bloc.add(const NextQuestion());
    } else {
      _completeQuiz(context, state);
    }
  }

  void _navigateToQuestion(BuildContext context, int questionIndex, QuizState state) {
    if (isBlocked || questionIndex == state.currentQuestionIndex) return;
    
    if (questionIndex >= 0 && questionIndex < widget.questions.length) {
      context.read<QuizBloc>().add(NavigateToQuestion(questionIndex));
    }
  }

  Future<bool> _onWillPop(BuildContext context, QuizState state) async {
    if (state.quizCompleted) {
      return true;
    }

    final bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Quiz?'),
          content: Text(
            state.selectedAnswers.isNotEmpty
                ? 'You have answered ${state.selectedAnswers.length} out of ${widget.questions.length} questions. Your progress will be lost if you exit now.'
                : 'Are you sure you want to exit the quiz?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  void _completeQuiz(BuildContext context, QuizState state) {
    final bloc = context.read<QuizBloc>();
    
    // Validate that all questions are answered
    if (state.selectedAnswers.length < widget.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before finishing the quiz.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Mark quiz as completed
    bloc.add(const QuizCompleted());
    
    AppLogger.feature('Quiz', 'Quiz completed with ${state.selectedAnswers.length} answers');
  }

  void _handleQuizCompletion(BuildContext context, QuizState state) {
    // Create correct answers map
    final Map<int, int> correctAnswers = {};
    for (int i = 0; i < widget.questions.length; i++) {
      correctAnswers[i] = widget.questions[i]['correctAnswerIndex'];
    }
    
    // Calculate results
    final correctCount = QuizValidationService.getCorrectAnswersCount(
      state.selectedAnswers,
      correctAnswers,
      widget.questions,
    );
    final incorrectCount = QuizValidationService.getIncorrectAnswersCount(
      state.selectedAnswers,
      correctAnswers,
      widget.questions,
    );

    // Process incorrect categories
    final List<String> incorrectCategories = [];
    for (final entry in state.selectedAnswers.entries) {
      final questionIndex = entry.key;
      final selectedAnswer = entry.value;
      final correctAnswerIndex = correctAnswers[questionIndex];
      
      if (correctAnswerIndex != null && questionIndex < widget.questions.length) {
        final question = widget.questions[questionIndex];
        final options = question['options'] as List<String>;
        
        if (correctAnswerIndex < options.length) {
          final correctAnswerText = options[correctAnswerIndex];
          if (selectedAnswer != correctAnswerText) {
            final category = question['category'] as String? ?? 'General';
            if (!incorrectCategories.contains(category)) {
              incorrectCategories.add(category);
            }
          }
        }
      }
    }

    if (incorrectCategories.isNotEmpty) {
      processCategories(
        incorrectCategories,
        widget.questions.isNotEmpty ? widget.questions[0]['quiz'] : '',
      ).then((success) {
        AppLogger.feature('Quiz', 'Process categories result: $success');
      });
    }

    // Show completion dialog
    QuizController.showQuizCompletedDialog(
      context,
      correctCount,
      widget.questions.length,
      incorrectCount,
    );
  }
}
