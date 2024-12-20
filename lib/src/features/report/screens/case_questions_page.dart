

import 'package:flutter/material.dart';

class CaseQuestionsPage extends StatelessWidget {
  final String caseName;
  final List<String> questions;

  const CaseQuestionsPage(this.caseName, this.questions, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(caseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCaseTitle(),
            const SizedBox(height: 20),
            _buildQuestionList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle submission of answers
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseTitle() {
    return Text(
      'Report $caseName',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuestionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: questions.map((question) {
        return CheckboxListTile(
          title: Text(question),
          controlAffinity: ListTileControlAffinity.leading,
          value: false, // Implement logic for checkbox state
          onChanged: (bool? value) {
            // Implement logic for handling checkbox state change
          },
        );
      }).toList(),
    );
  }
}
