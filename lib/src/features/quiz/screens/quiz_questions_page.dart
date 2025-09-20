import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/quiz/quiz.dart';
import 'package:guardiancare/src/features/quiz/common_widgets/quiz_question_widget.dart';
import 'package:guardiancare/src/features/explore/screens/explore.dart';

class QuizQuestionsPage extends StatefulWidget {
  final String quizName;

  const QuizQuestionsPage({super.key, required this.quizName});

  @override
  State<QuizQuestionsPage> createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  @override
  void initState() {
    super.initState();
    // Start the quiz when page loads
    final quizBloc = context.read<QuizBloc>();
    final currentState = quizBloc.state;
    
    if (currentState is QuizQuestionsLoaded && 
        currentState.quizName == widget.quizName) {
      // Questions already loaded, start the quiz
      quizBloc.add(QuizStartRequested(widget.quizName));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Questions'),
      ),
      body: BlocListener<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizCompleted) {
            _showQuizCompletedDialog(state.result);
          } else if (state is QuizError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<QuizBloc, QuizState>(
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QuizQuestionsLoaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ready to start ${state.quizName}?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: tPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${state.questions.length} questions',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        context.read<QuizBloc>().add(
                          QuizStartRequested(state.quizName),
                        );
                      },
                      child: const Text('Start Quiz'),
                    ),
                  ],
                ),
              );
            } else if (state is QuizInProgress) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    LinearProgressIndicator(
                      value: (state.currentQuestionIndex + 1) / state.totalQuestions,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(tPrimaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestions}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: QuizQuestionWidget(
                        questionIndex: state.currentQuestionIndex + 1,
                        correctAnswerIndex: state.currentQuestion.correctAnswerIndex,
                        question: {
                          'question': state.currentQuestion.question,
                          'options': state.currentQuestion.options,
                        },
                        onPressed: (int selectedOptionIndex) {
                          if (!state.isBlocked) {
                            context.read<QuizBloc>().add(
                              QuizAnswerSubmitted(
                                questionIndex: state.currentQuestionIndex,
                                selectedAnswerIndex: selectedOptionIndex,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!state.isFirstQuestion)
                          ElevatedButton(
                            onPressed: state.isBlocked ? null : () {
                              context.read<QuizBloc>().add(
                                const QuizPreviousQuestionRequested(),
                              );
                            },
                            child: const Text(
                              'Previous',
                              style: TextStyle(color: tPrimaryColor),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        ElevatedButton(
                          onPressed: state.isBlocked ? null : () {
                            context.read<QuizBloc>().add(
                              const QuizNextQuestionRequested(),
                            );
                          },
                          child: Text(
                            state.isLastQuestion ? 'Finish' : 'Next',
                            style: const TextStyle(color: tPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else if (state is QuizError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }
            
            // Default case
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _showQuizCompletedDialog(QuizResult result) {
    String message;
    Widget content;

    if (result.incorrectAnswers == 0) {
      // All answers are correct
      message =
          'Congratulations! You have completed all the questions.\n\nScore: ${result.scoreText}.\n\nKeep on learning! ✨';
      content = Text(message);
    } else {
      // Some answers are incorrect
      message =
          'Thanks for completing the quiz!\n\nScore: ${result.scoreText}.\n\nVisit ';
      content = RichText(
        text: TextSpan(
          text: message,
          style: const TextStyle(color: Colors.black),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  Future.delayed(const Duration(seconds: 2)).then((_) {
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Explore()),
                      );
                    }
                  });
                },
                child: const Text(
                  'Recommended',
                  style: TextStyle(
                      color: tPrimaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const TextSpan(
              text: ' section to boost your score next time. 😇',
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Quiz Completed',
            style: TextStyle(fontWeight: FontWeight.bold, color: tPrimaryColor),
          ),
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
