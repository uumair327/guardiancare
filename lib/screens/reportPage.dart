import 'package:flutter/material.dart';

import 'homePage.dart'; // Import the HomePage widget

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Incident Type:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(
                  value: 'environmental_safety',
                  child: Text('Environmental Safety'),
                ),
                DropdownMenuItem(
                  value: 'online_safety',
                  child: Text('Online Safety'),
                ),
                DropdownMenuItem(
                  value: 'educational_safety',
                  child: Text('Educational Safety'),
                ),
                DropdownMenuItem(
                  value: 'mental_health',
                  child: Text('Mental Health'),
                ),
                DropdownMenuItem(
                  value: 'community_safety',
                  child: Text('Community Safety'),
                ),
                DropdownMenuItem(
                  value: 'positive_development',
                  child: Text('Promoting Positive Development'),
                ),
              ],
              onChanged: (value) {
                // Implement logic based on selected incident type
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select Incident Type',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _submitReport(context); // Call function to submit report
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to handle report submission
  void _submitReport(BuildContext context) {
    // Perform submission logic here
    // For demonstration purposes, let's show a success dialog
    _showSuccessDialog(context);
  }

  // Function to show success dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Incident report submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const HomePage()), // Navigate to HomePage
                (route) => false, // Clear all previous routes
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
