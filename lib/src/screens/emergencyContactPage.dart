import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Emergency Contact'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emergency services section
                _buildCard(
                  icon: Icons.local_hospital,
                  title: 'Emergency Services',
                  contacts: [
                    {'name': 'Police', 'number': '911'},
                    {'name': 'Fire Department', 'number': '911'},
                    {'name': 'Medical Emergency', 'number': '911'},
                  ],
                ),
                const SizedBox(height: 20),
                // Child safety section
                _buildCard(
                  icon: Icons.child_care,
                  title: 'Child Safety',
                  contacts: [
                    {'name': 'National Center for Missing & Exploited Children', 'number': '1-800-843-5678'},
                    {'name': 'Childhelp National Child Abuse Hotline', 'number': '1-800-422-4453'},
                    {'name': 'Poison Control Center', 'number': '1-800-222-1222'},
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Map<String, String>> contacts,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contacts
                  .map((contact) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _launchPhone(contact['number']!);
                  },
                  icon: Icon(
                    Icons.phone,
                    size: 20,
                  ),
                  label: Text(
                    '${contact['name']}: ${contact['number']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green), // Use MaterialStateProperty.all<Color> to set background color
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 10, horizontal: 15)),
                  ),
                ),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _launchPhone(String phoneNumber) async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneLaunchUri.toString())) {
      await launch(phoneLaunchUri.toString());
    } else {
      throw 'Could not launch $phoneLaunchUri';
    }
  }
}
