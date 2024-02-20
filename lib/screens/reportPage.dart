import 'package:flutter/material.dart';
import 'homePage.dart'; // Import the HomePage widget

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Incident'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Incident Type:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              items: [
                DropdownMenuItem(
                  child: Text('Environmental Safety'),
                  value: 'environmental_safety',
                ),
                DropdownMenuItem(
                  child: Text('Online Safety'),
                  value: 'online_safety',
                ),
                DropdownMenuItem(
                  child: Text('Educational Safety'),
                  value: 'educational_safety',
                ),
                DropdownMenuItem(
                  child: Text('Mental Health'),
                  value: 'mental_health',
                ),
                DropdownMenuItem(
                  child: Text('Community Safety'),
                  value: 'community_safety',
                ),
                DropdownMenuItem(
                  child: Text('Promoting Positive Development'),
                  value: 'positive_development',
                ),
              ],
              onChanged: (value) {
                // Implement logic based on selected incident type
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select Incident Type',
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _submitReport(context); // Call function to submit report
              },
              child: Text('Submit'),
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
        title: Text('Success'),
        content: Text('Incident report submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()), // Navigate to HomePage
                    (route) => false, // Clear all previous routes
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
