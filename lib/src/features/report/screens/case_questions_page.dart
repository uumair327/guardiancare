
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import '../models/report_category.dart';

class CaseQuestionsPage extends StatefulWidget {
  final ReportCategory category;
  final Function(Map<String, bool>) onAnswersSubmitted;

  const CaseQuestionsPage({
    super.key,
    required this.category,
    required this.onAnswersSubmitted,
  });

  @override
  State<CaseQuestionsPage> createState() => _CaseQuestionsPageState();
}

class _CaseQuestionsPageState extends State<CaseQuestionsPage> {
  final Map<String, bool> _answers = {};

  @override
  void initState() {
    super.initState();
    // Initialize all answers to false
    for (final question in widget.category.questions) {
      _answers[question] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCaseTitle(),
            const SizedBox(height: 8),
            _buildCaseDescription(),
            const SizedBox(height: 20),
            _buildQuestionList(),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submitAnswers,
              child: const Text(
                'Submit Answers',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseTitle() {
    return Text(
      'Report ${widget.category.name}',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCaseDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.category.description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please answer the following questions:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.category.questions.map((question) {
              return CheckboxListTile(
                title: Text(question),
                controlAffinity: ListTileControlAffinity.leading,
                value: _answers[question] ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    _answers[question] = value ?? false;
                  });
                },
                activeColor: tPrimaryColor,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _submitAnswers() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Answers'),
        content: const Text('Are you sure you want to submit your answers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: tPrimaryColor),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onAnswersSubmitted(_answers);
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
