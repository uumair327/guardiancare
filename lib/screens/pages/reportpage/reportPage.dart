import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late String _selectedIncidentType = 'environmental_safety';
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _recipientEmailController =
      TextEditingController();

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
            Text(
              'Select Incident Type *:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedIncidentType,
              items: const [
                DropdownMenuItem(
                  value: 'environmental_safety',
                  child: Text('Environmental Safety'),
                ),
                DropdownMenuItem(
                  value: 'online_safety',
                  child: Text('Online Safety'),
                ),
                // ... (other incident types)
              ],
              onChanged: (value) {
                setState(() {
                  _selectedIncidentType = value!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select Incident Type',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientEmailController,
              decoration: const InputDecoration(
                labelText: 'Recipient Email(s) (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) {
                  return null; // No validation for empty field (optional)
                }
                final emailRegex = RegExp(r"[^@]+@[^@]+\.[^@]+");
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_validateInput()) {
                  _submitReport(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to validate input fields
  bool _validateInput() {
    return _locationController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty;
  }

  // Function to handle report submission (using Flutter Email Sender)
  Future<void> _submitReport(BuildContext context) async {
    final recipientEmails =
        _recipientEmailController.text.split(',').map((e) => e.trim()).toList();

    // Prepare email content
    final emailBody = StringBuffer();
    emailBody.write('Incident Type: $_selectedIncidentType\n');
    emailBody.write('Location: $_locationController.text\n');
    emailBody.write('Description: $_descriptionController.text\n');

    // Use Flutter Email Sender for efficient email composition
    final emailRecipient = recipientEmails.isNotEmpty
        ? recipientEmails[0]
        : 'mohdumair.a@somaiya.edu';
    final email = Email(
      // recipient: emailRecipient,
      subject: 'Incident Report',
      body: emailBody.toString(),
    );

    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident report submitted successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending report: $error'),
        ),
      );
    }
  }
}
