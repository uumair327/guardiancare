import 'package:flutter/material.dart';

import 'CaseQuestionsPage.dart'; // Import the CaseQuestionsPage

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        _buildCardButton(
            context, 'Environmental Safety', _environmentalSafetySubTopics),
        SizedBox(height: 10),
        _buildCardButton(context, 'Online Safety', _onlineSafetySubTopics),
        SizedBox(height: 10),
        _buildCardButton(
            context, 'Educational Safety', _educationalSafetySubTopics),
        SizedBox(height: 10),
        _buildCardButton(context, 'Mental Health', _mentalHealthSubTopics),
        SizedBox(height: 10),
        _buildCardButton(
            context, 'Community Safety', _communitySafetySubTopics),
        SizedBox(height: 10),
        _buildCardButton(context, 'Promoting Positive Development',
            _positiveDevelopmentSubTopics),
      ],
    );
  }

  Widget _buildCardButton(
      BuildContext context, String category, List<String> subTopics) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CaseQuestionsPage(category, subTopics),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: subTopics
                    .map(
                      (subTopic) => ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CaseQuestionsPage(category, [subTopic]),
                            ),
                          );
                        },
                        child: Text(subTopic),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
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
