import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_state_manager.dart';

class QuizQuestionWidget extends StatefulWidget {
  final int questionIndex;
  final int correctAnswerIndex;
  final Map<String, dynamic> question;
  final Function(int, bool) onAnswerSelected;
  final QuizStateManager stateManager;
  final bool showQuestionNumber;
  final VoidCallback? onFeedbackComplete;

  const QuizQuestionWidget({
    Key? key,
    required this.questionIndex,
    required this.correctAnswerIndex,
    required this.question,
    required this.onAnswerSelected,
    required this.stateManager,
    this.showQuestionNumber = true,
    this.onFeedbackComplete,
  }) : super(key: key);

  @override
  _QuizQuestionWidgetState createState() => _QuizQuestionWidgetState();
}

class _QuizQuestionWidgetState extends State<QuizQuestionWidget> 
    with TickerProviderStateMixin {
  bool _showingFeedback = false;
  bool _isProcessingAnswer = false;
  Timer? _feedbackTimer;
  late AnimationController _feedbackAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Initialize animations
    _feedbackAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _feedbackAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to state manager changes
    widget.stateManager.addListener(_onStateChanged);
    
    // Check if feedback should already be shown for this question
    _updateFeedbackState();
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
      _resetFeedbackState();
      _updateFeedbackState();
    }
  }

  void _onStateChanged() {
    if (mounted) {
      _updateFeedbackState();
      setState(() {
        // Trigger rebuild when state manager changes
      });
    }
  }

  void _updateFeedbackState() {
    final shouldShowFeedback = widget.stateManager.hasFeedbackBeenShown(widget.questionIndex);
    if (shouldShowFeedback != _showingFeedback) {
      setState(() {
        _showingFeedback = shouldShowFeedback;
      });
      
      if (shouldShowFeedback) {
        _feedbackAnimationController.forward();
      } else {
        _feedbackAnimationController.reset();
      }
    }
  }

  void _resetFeedbackState() {
    _feedbackTimer?.cancel();
    _feedbackAnimationController.reset();
    _buttonAnimationController.reset();
    setState(() {
      _showingFeedback = false;
      _isProcessingAnswer = false;
    });
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _feedbackAnimationController.dispose();
    _buttonAnimationController.dispose();
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
            if (widget.showQuestionNumber) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${widget.questionIndex + 1}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tTextPrimary,
                    ),
                  ),
                  if (_isAnswerLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: tPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: tPrimaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock,
                            size: 16,
                            color: tPrimaryColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Locked',
                            style: TextStyle(
                              fontSize: 12,
                              color: tPrimaryColor.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Question text with enhanced styling
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Colors.grey[200]!,
                ),
              ),
              child: Text(
                widget.question['question'],
                style: const TextStyle(
                  fontSize: 18,
                  color: tTextPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Answer options with enhanced styling and animations
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    widget.question['options'].length,
                    (index) => _buildAnswerOption(index),
                  ),
                ),
              ),
            ),
            
            // Processing indicator
            if (_isProcessingAnswer)
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(tPrimaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Processing answer...',
                      style: TextStyle(
                        color: tTextPrimary,
                        fontSize: 14,
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

  Widget _buildAnswerOption(int index) {
    final isSelected = _selectedIndex == index;
    final isCorrect = index == widget.correctAnswerIndex;
    final canSelect = _canSelectAnswer(index);
    
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected && _isProcessingAnswer ? _buttonScaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  if (isSelected && !_isAnswerLocked)
                    BoxShadow(
                      color: tPrimaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canSelect ? () => _selectAnswer(index) : null,
                  borderRadius: BorderRadius.circular(16.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getButtonColor(index),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: _getBorderColor(index),
                        width: 2.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Option letter/number
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getOptionIndicatorColor(index),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: TextStyle(
                                color: _getOptionIndicatorTextColor(index),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Option text
                        Expanded(
                          child: Text(
                            widget.question['options'][index],
                            style: TextStyle(
                              color: _getTextColor(index),
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        
                        // Status icon with animation
                        if (isSelected)
                          AnimatedBuilder(
                            animation: _feedbackAnimation,
                            builder: (context, child) {
                              if (_showingFeedback) {
                                return Transform.scale(
                                  scale: _feedbackAnimation.value,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isCorrect ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                );
                              } else if (_isAnswerLocked) {
                                return Icon(
                                  Icons.lock,
                                  color: _getTextColor(index).withOpacity(0.7),
                                  size: 20,
                                );
                              } else if (_isProcessingAnswer) {
                                return SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getTextColor(index),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Check if user can select an answer for the given option index
  bool _canSelectAnswer(int optionIndex) {
    return !widget.stateManager.isQuestionLocked(widget.questionIndex) && 
           !_isProcessingAnswer;
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

  /// Check if this question has been answered
  bool get _isQuestionAnswered {
    return widget.stateManager.isQuestionAnswered(widget.questionIndex);
  }

  void _selectAnswer(int index) async {
    // Double-check that we can still select an answer
    if (!_canSelectAnswer(index)) return;

    // Prevent multiple simultaneous selections
    if (_isProcessingAnswer) return;

    setState(() {
      _isProcessingAnswer = true;
    });

    // Animate button press
    await _buttonAnimationController.forward();
    await _buttonAnimationController.reverse();

    // Get the answer text from the options
    final options = widget.question['options'] as List<String>;
    final answerText = options[index];

    // Try to select the answer in the state manager
    final bool answerSelected = widget.stateManager.selectAnswer(widget.questionIndex, answerText);
    
    if (!answerSelected) {
      print('QuizQuestionWidget: Failed to select answer for question ${widget.questionIndex}');
      setState(() {
        _isProcessingAnswer = false;
      });
      return;
    }

    // Determine if the answer is correct
    final bool isCorrect = index == widget.correctAnswerIndex;

    // Show feedback and lock the question
    widget.stateManager.showFeedback(widget.questionIndex);

    // Update state to show feedback
    setState(() {
      _showingFeedback = true;
      _isProcessingAnswer = false;
    });

    // Start feedback animation
    _feedbackAnimationController.forward();

    // Call the parent callback with answer correctness
    widget.onAnswerSelected(index, isCorrect);

    // Show feedback for 2.5 seconds, then complete
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        // Call completion callback if provided
        widget.onFeedbackComplete?.call();
      }
    });
  }

  Color _getButtonColor(int index) {
    final selectedIndex = _selectedIndex;
    final isSelected = selectedIndex == index;
    final isCorrect = index == widget.correctAnswerIndex;
    
    // If this option is selected and we're showing feedback
    if (isSelected && _showingFeedback) {
      return isCorrect ? Colors.green[50]! : Colors.red[50]!;
    } 
    // If this option is selected but not showing feedback
    else if (isSelected) {
      if (_isAnswerLocked) {
        return tPrimaryColor.withOpacity(0.1);
      } else {
        return tPrimaryColor.withOpacity(0.1);
      }
    }
    // Default state
    return Colors.white;
  }

  Color _getBorderColor(int index) {
    final selectedIndex = _selectedIndex;
    final isSelected = selectedIndex == index;
    final isCorrect = index == widget.correctAnswerIndex;
    
    // If this option is selected and we're showing feedback
    if (isSelected && _showingFeedback) {
      return isCorrect ? Colors.green : Colors.red;
    } 
    // If this option is selected but not showing feedback
    else if (isSelected) {
      return tPrimaryColor;
    }
    // Default state
    return Colors.grey[300]!;
  }

  Color _getTextColor(int index) {
    final selectedIndex = _selectedIndex;
    final isSelected = selectedIndex == index;
    final isCorrect = index == widget.correctAnswerIndex;
    
    // If this option is selected and we're showing feedback
    if (isSelected && _showingFeedback) {
      return isCorrect ? Colors.green[700]! : Colors.red[700]!;
    } 
    // If this option is selected (locked state)
    else if (isSelected) {
      return tPrimaryColor;
    }
    // Default state
    return tTextPrimary;
  }

  Color _getOptionIndicatorColor(int index) {
    final selectedIndex = _selectedIndex;
    final isSelected = selectedIndex == index;
    final isCorrect = index == widget.correctAnswerIndex;
    
    // If this option is selected and we're showing feedback
    if (isSelected && _showingFeedback) {
      return isCorrect ? Colors.green : Colors.red;
    } 
    // If this option is selected but not showing feedback
    else if (isSelected) {
      return tPrimaryColor;
    }
    // Default state
    return Colors.grey[200]!;
  }

  Color _getOptionIndicatorTextColor(int index) {
    final selectedIndex = _selectedIndex;
    final isSelected = selectedIndex == index;
    
    // If this option is selected
    if (isSelected) {
      return Colors.white;
    }
    // Default state
    return tTextPrimary;
  }
}
