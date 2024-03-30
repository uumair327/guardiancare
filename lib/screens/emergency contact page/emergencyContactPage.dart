import 'package:flutter/material.dart';

class EmergencyContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Emergency Contact'),
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
                    'Police: 911',
                    'Fire Department: 911',
                    'Medical Emergency: 911',
                  ],
                ),
                SizedBox(height: 20),
                // Child safety section
                _buildCard(
                  icon: Icons.child_care,
                  title: 'Child Safety',
                  contacts: [
                    'National Center for Missing & Exploited Children: 1-800-843-5678',
                    'Childhelp National Child Abuse Hotline: 1-800-422-4453',
                    'Poison Control Center: 1-800-222-1222',
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
    required List<String> contacts,
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
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contacts
                  .map((contact) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          contact,
                          style: TextStyle(
                            fontSize: 16,
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
}
