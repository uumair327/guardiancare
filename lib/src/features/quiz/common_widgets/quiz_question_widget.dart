import 'package:flutter/material.dart';
import 'package:guardianscare/src/constants/colors.dart';

class QuizQuestionWidget extends StatefulWidget {
  final int questionIndex;
  final int correctAnswerIndex;
  final Map<String, dynamic> question;
  final Function(int) onPressed;

  const QuizQuestionWidget({
    Key? key,
    required this.questionIndex,
    required this.correctAnswerIndex,
    required this.question,
    required this.onPressed,
  }) : super(key: key);

  @override
  _QuizQuestionWidgetState createState() => _QuizQuestionWidgetState();
}

class _QuizQuestionWidgetState extends State<QuizQuestionWidget> {
  int? selectedIndex;

  @override
  void didUpdateWidget(QuizQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.questionIndex != oldWidget.questionIndex) {
      setState(() {
        selectedIndex = null;
      });
    }
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
                    onPressed: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      widget.onPressed(index);
                    },
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
                    child: Text(
                      widget.question['options'][index],
                      style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.white
                            : tPrimaryColor,
                      ),
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

  Color getButtonColor(int index) {
    if (selectedIndex == index) {
      return index == widget.correctAnswerIndex ? Colors.green : Colors.red;
    }
    return Colors.white;
  }
}
