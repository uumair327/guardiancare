import 'package:flutter/material.dart';
import 'package:guardiancare/src/api/gemini/process_categories.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/quiz/common_widgets/quiz_question_widget.dart';
import 'package:guardiancare/src/features/quiz/controllers/quiz_controller.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_state_manager.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_validation_service.dart';

class QuizQuestionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  QuizQuestionsPage({required this.questions});

  @override
  _QuizQuestionsPageState createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  int currentQuestionIndex = 0; // Index of the current question
  bool isBlocked = false; // Flag to block next actions during feedback
  late QuizStateManager _stateManager;

  @override
  void initState() {
    super.initState();
    // Initialize the quiz state manager
    _stateManager = QuizStateManager();
    _stateManager.addListener(_onQuizStateChanged);
  }

  @override
  void dispose() {
    _stateManager.removeListener(_onQuizStateChanged);
    _stateManager.dispose();
    super.dispose();
  }

  void _onQuizStateChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when quiz state changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quiz Questions (${currentQuestionIndex + 1}/${widget.questions.length})'),
          actions: [
            // Progress indicator in app bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '${(_stateManager.getProgress(widget.questions.length) * 100).toInt()}%',
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
              value: _stateManager.getProgress(widget.questions.length),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(tPrimaryColor),
            ),
            const SizedBox(height: 8),
            // Question navigation dots
            _buildQuestionNavigationDots(),
            const SizedBox(height: 16),
            if (currentQuestionIndex < widget.questions.length)
              Expanded(
                child: QuizQuestionWidget(
                  questionIndex: currentQuestionIndex,
                  correctAnswerIndex: widget.questions[currentQuestionIndex]
                      ['correctAnswerIndex'],
                  question: widget.questions[currentQuestionIndex],
                  stateManager: _stateManager,
                  onAnswerSelected: (int selectedOptionIndex, bool isCorrect) {
                    // The state manager now handles answer locking
                    // Just block navigation temporarily for feedback display
                    setState(() {
                      isBlocked = true;
                    });

                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          isBlocked = false;
                        });
                      }
                    });
                  },
                ),
              ),
            if (currentQuestionIndex >= widget.questions.length)
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: _canGoToPrevious() ? _goToPreviousQuestion : null,
                    child: const Text(
                      'Previous',
                      style: TextStyle(
                        color: tPrimaryColor,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _canGoToNext() ? _goToNextQuestion : null,
                  child: Text(
                    currentQuestionIndex == widget.questions.length - 1
                        ? 'Finish'
                        : 'Next',
                    style: const TextStyle(
                      color: tPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Handle back button press with confirmation
  Future<bool> _onWillPop() async {
    if (_stateManager.isQuizCompleted) {
      return true; // Allow navigation if quiz is completed
    }

    // Show confirmation dialog if quiz is in progress
    final bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Quiz?'),
          content: Text(
            _stateManager.answeredQuestionsCount > 0
                ? 'You have answered ${_stateManager.answeredQuestionsCount} out of ${widget.questions.length} questions. Your progress will be lost if you exit now.'
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

  /// Check if user can navigate to previous question
  bool _canGoToPrevious() {
    return !isBlocked && currentQuestionIndex > 0;
  }

  /// Check if user can navigate to next question
  bool _canGoToNext() {
    if (isBlocked) return false;
    
    // For the last question, check if we can complete the quiz
    if (currentQuestionIndex == widget.questions.length - 1) {
      return _stateManager.isQuestionAnswered(currentQuestionIndex);
    }
    
    // For other questions, check if current question is answered
    return _stateManager.isQuestionAnswered(currentQuestionIndex);
  }

  void _goToPreviousQuestion() {
    if (!_canGoToPrevious()) return;
    
    setState(() {
      currentQuestionIndex--;
      _stateManager.navigateToQuestion(currentQuestionIndex);
    });
  }

  void _goToNextQuestion() {
    if (!_canGoToNext()) {
      // Show message if current question hasn't been answered
      if (!_stateManager.isQuestionAnswered(currentQuestionIndex)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please answer the current question first.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _stateManager.navigateToQuestion(currentQuestionIndex);
      });
    } else {
      // Complete the quiz
      _completeQuiz();
    }
  }

  /// Build question navigation dots showing answered/current/unanswered status
  Widget _buildQuestionNavigationDots() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final isAnswered = _stateManager.isQuestionAnswered(index);
          final isCurrent = index == currentQuestionIndex;
          final isLocked = _stateManager.isQuestionLocked(index);
          
          Color dotColor;
          if (isCurrent) {
            dotColor = tPrimaryColor;
          } else if (isAnswered && isLocked) {
            // For locked questions, we need to determine correctness
            final selectedAnswer = _stateManager.getSelectedAnswer(index);
            final correctAnswerIndex = widget.questions[index]['correctAnswerIndex'];
            final options = widget.questions[index]['options'] as List<String>;
            final correctAnswer = options[correctAnswerIndex];
            dotColor = selectedAnswer == correctAnswer ? Colors.green : Colors.red;
          } else if (isAnswered) {
            dotColor = Colors.orange; // Answered but not locked yet
          } else {
            dotColor = Colors.grey[400]!;
          }

          return GestureDetector(
            onTap: () => _navigateToQuestion(index),
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

  /// Navigate to a specific question (only if navigation is allowed)
  void _navigateToQuestion(int questionIndex) {
    if (isBlocked || questionIndex == currentQuestionIndex) return;
    
    // Allow navigation to any question, but preserve locked answers
    if (_canNavigateToQuestion(questionIndex)) {
      setState(() {
        currentQuestionIndex = questionIndex;
        _stateManager.navigateToQuestion(questionIndex);
      });
    }
  }

  /// Enhanced navigation validation with better user feedback
  bool _canNavigateToQuestion(int targetIndex) {
    if (isBlocked) return false;
    if (targetIndex < 0 || targetIndex >= widget.questions.length) return false;
    
    // Allow navigation to any question - locked answers are preserved
    return true;
  }

  void _completeQuiz() {
    // Validate that all questions are answered before completing
    if (!QuizValidationService.isQuizComplete(widget.questions, _stateManager)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before finishing the quiz.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Mark quiz as completed in state manager
    _stateManager.completeQuiz();
    
    // Create correct answers map for validation service
    final Map<int, int> correctAnswers = {};
    for (int i = 0; i < widget.questions.length; i++) {
      correctAnswers[i] = widget.questions[i]['correctAnswerIndex'];
    }
    
    // Calculate final results using the validation service
    final selectedAnswers = _stateManager.selectedAnswers;
    final correctCount = QuizValidationService.getCorrectAnswersCount(
      selectedAnswers, 
      correctAnswers, 
      widget.questions
    );
    final incorrectCount = QuizValidationService.getIncorrectAnswersCount(
      selectedAnswers, 
      correctAnswers, 
      widget.questions
    );

    // Process incorrect categories for recommendations
    final List<String> incorrectCategories = [];
    for (final entry in selectedAnswers.entries) {
      final questionIndex = entry.key;
      final selectedAnswer = entry.value;
      final correctAnswerIndex = correctAnswers[questionIndex];
      
      if (correctAnswerIndex != null && questionIndex < widget.questions.length) {
        final question = widget.questions[questionIndex];
        final options = question['options'] as List<String>;
        
        if (correctAnswerIndex < options.length) {
          final correctAnswerText = options[correctAnswerIndex];
          if (selectedAnswer != correctAnswerText) {
            // Add category for incorrect answer
            final category = question['category'] as String? ?? 'General';
            if (!incorrectCategories.contains(category)) {
              incorrectCategories.add(category);
            }
          }
        }
      }
    }

    if (incorrectCategories.isNotEmpty) {
      Future<bool> processSuccess = processCategories(
        incorrectCategories, 
        widget.questions.isNotEmpty ? widget.questions[0]['quiz'] : ''
      );
      print('Process categories result: $processSuccess');
    }

    // Show quiz completed dialog with results from state manager
    QuizController.showQuizCompletedDialog(
      context,
      correctCount,
      widget.questions.length,
      incorrectCount,
    );
  }
}
