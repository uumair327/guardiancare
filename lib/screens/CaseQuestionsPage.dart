

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CaseQuestionsPage extends StatelessWidget {
  final String caseName;
  final List<String> questions;

  CaseQuestionsPage(this.caseName, this.questions);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(caseName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCaseTitle(),
            SizedBox(height: 20),
            _buildQuestionList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle submission of answers
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseTitle() {
    return Text(
      'Report $caseName',
      style: TextStyle(
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
