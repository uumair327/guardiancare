import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_state_manager.dart';

class QuizQuestionWidget extends StatefulWidget {
  final int questionIndex;
  final int correctAnswerIndex;
  final Map<String, dynamic> question;
  final Function(int, bool) onAnswerSelected; // Updated to include correctness
  final QuizStateManager stateManager;

  const QuizQuestionWidget({
    Key? key,
    required this.questionIndex,
    required this.correctAnswerIndex,
    required this.question,
    required this.onAnswerSelected,
    required this.stateManager,
  }) : super(key: key);

  @override
  _QuizQuestionWidgetState createState() => _QuizQuestionWidgetState();
}

class _QuizQuestionWidgetState extends State<QuizQuestionWidget> {
  bool showingFeedback = false;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    // Listen to state manager changes
    widget.stateManager.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(QuizQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update listener if state manager changed
    if (widget.stateManager != oldWidget.stateManager) {
      oldWidget.stateManager.removeListener(_onStateChanged);
      widget.stateManager.addListener(_onStateChanged);
    }
    
    // Reset feedback state when question changes
    if (widget.questionIndex != oldWidget.questionIndex) {
      _feedbackTimer?.cancel();
      setState(() {
        showingFeedback = false;
      });
    }
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when state manager changes
      });
    }
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    widget.stateManager.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${widget.questionIndex}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: tTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.question['question'],
              style: const TextStyle(
                fontSize: 20,
                color: tTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              widget.question['options'].length,
              (index) => SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: _canSelectAnswer(index) ? () {
                      _selectAnswer(index);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(color: tPrimaryColor),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                      backgroundColor: getButtonColor(index),
                      foregroundColor: tTextPrimary,
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.question['options'][index],
                            style: TextStyle(
                              color: getTextColor(index),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (_selectedIndex == index && _isAnswerLocked)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              showingFeedback 
                                ? (index == widget.correctAnswerIndex ? Icons.check_circle : Icons.cancel)
                                : Icons.lock,
                              color: getTextColor(index),
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if user can select an answer for the given option index
  bool _canSelectAnswer(int optionIndex) {
    return !widget.stateManager.isQuestionLocked(widget.questionIndex);
  }

  /// Get the currently selected answer index from state manager
  String? get _selectedAnswer {
    return widget.stateManager.getSelectedAnswer(widget.questionIndex);
  }

  /// Get the selected answer index (convert from string to index)
  int? get _selectedIndex {
    final selectedAnswer = _selectedAnswer;
    if (selectedAnswer == null) return null;
    
    // Find the index of the selected answer in the options
    final options = widget.question['options'] as List<String>;
    return options.indexOf(selectedAnswer);
  }

  /// Check if the answer is locked (already answered)
  bool get _isAnswerLocked {
    return widget.stateManager.isQuestionLocked(widget.questionIndex);
  }

  void _selectAnswer(int index) {
    // Double-check that we can still select an answer
    if (!_canSelectAnswer(index)) return;

    // Get the answer text from the options
    final options = widget.question['options'] as List<String>;
    final answerText = options[index];

    // Try to select the answer in the state manager
    final bool answerSelected = widget.stateManager.selectAnswer(widget.questionIndex, answerText);
    
    if (!answerSelected) {
      print('QuizQuestionWidget: Failed to select answer for question ${widget.questionIndex}');
      return;
    }

    // Determine if the answer is correct
    final bool isCorrect = index == widget.correctAnswerIndex;

    // Show feedback immediately
    setState(() {
      showingFeedback = true;
    });

    // Show feedback and lock the question
    widget.stateManager.showFeedback(widget.questionIndex);

    // Call the parent callback with answer correctness
    widget.onAnswerSelected(index, isCorrect);

    // Show feedback for 2 seconds, then hide it
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showingFeedback = false;
        });
      }
    });
  }

  Color getButtonColor(int index) {
    final selectedIndex = _selectedIndex;
    
    // If this option is selected and we're showing feedback
    if (selectedIndex == index && showingFeedback) {
      return index == widget.correctAnswerIndex ? Colors.green : Colors.red;
    } 
    // If this option is selected but not showing feedback (locked state)
    else if (selectedIndex == index) {
      return _isAnswerLocked ? tPrimaryColor.withOpacity(0.3) : tPrimaryColor.withOpacity(0.3);
    }
    // Default state
    return Colors.white;
  }

  Color getTextColor(int index) {
    final selectedIndex = _selectedIndex;
    
    // If this option is selected and we're showing feedback
    if (selectedIndex == index && showingFeedback) {
      return Colors.white;
    } 
    // If this option is selected (locked state)
    else if (selectedIndex == index) {
      return Colors.white;
    }
    // Default state
    return tPrimaryColor;
  }
}
