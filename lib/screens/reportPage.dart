import 'package:flutter/material.dart';
import 'CaseQuestionsPage.dart'; // Import the CaseQuestionsPage

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report an Issue'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReportTitle(),
            SizedBox(height: 20),
            _buildCategoryButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTitle() {
    return Text(
      'Report an Issue',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildButton(context, 'Environmental Safety', _environmentalSafetySubTopics),
        SizedBox(height: 10),
        _buildButton(context, 'Online Safety', _onlineSafetySubTopics),
        SizedBox(height: 10),
        _buildButton(context, 'Educational Safety', _educationalSafetySubTopics),
        SizedBox(height: 10),
        _buildButton(context, 'Mental Health', _mentalHealthSubTopics),
        SizedBox(height: 10),
        _buildButton(context, 'Community Safety', _communitySafetySubTopics),
        SizedBox(height: 10),
        _buildButton(context, 'Promoting Positive Development', _positiveDevelopmentSubTopics),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String category, List<String> subTopics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigate to the page with questions for the selected category
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CaseQuestionsPage(category, subTopics)),
            );
          },
          child: Text(category),
        ),
        SizedBox(height: 10),
        // Create buttons for each subtopic
        ...subTopics.map((subTopic) => ElevatedButton(
          onPressed: () {
            // Navigate to the page with questions for the selected subtopic
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CaseQuestionsPage(category, [subTopic])),
            );
          },
          child: Text(subTopic),
        )).toList(),
      ],
    );
  }

  // Subtopics for each category
  static const List<String> _environmentalSafetySubTopics = [
    'Poisoning',
    'Fire Safety',
    'Drowning',
    'Falls',
    'Exposure to dangerous chemicals or toxins',
  ];

  static const List<String> _onlineSafetySubTopics = [
    'Cyberbullying',
    'Exposure to inappropriate content',
    'Online predators',
    'Addiction to gaming or social media',
  ];

  static const List<String> _educationalSafetySubTopics = [
    'Physical violence or bullying',
    'Emotional abuse or neglect',
    'Exposure to hazardous materials or unsafe environments',
  ];

  static const List<String> _mentalHealthSubTopics = [
    'Anxiety and depression',
    'Eating disorders',
    'Self-harm or suicidal thoughts',
    'The impact of trauma or abuse',
  ];

  static const List<String> _communitySafetySubTopics = [
    'Gang violence',
    'Drug use and abuse',
    'Human trafficking',
    'Exposure to violence or crime',
  ];

  static const List<String> _positiveDevelopmentSubTopics = [
    'Providing access to quality education and healthcare',
    'Creating safe and nurturing environments',
    'Teaching children about safety and risk prevention',
    'Building strong and supportive relationships with children',
  ];
}
