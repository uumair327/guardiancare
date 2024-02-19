import 'package:flutter/material.dart';

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
                  child: Text('Accident'),
                  value: 'accident',
                ),
                DropdownMenuItem(
                  child: Text('Theft'),
                  value: 'theft',
                ),
                DropdownMenuItem(
                  child: Text('Fire'),
                  value: 'fire',
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
                // Implement submit button logic
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
