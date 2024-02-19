import 'package:flutter/material.dart';

class Account extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Name: John Doe'),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email: johndoe@example.com'),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Phone: +1 (123) 456-7890'),
              ),
              Divider(),
              Text(
                'Child Safety Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SwitchListTile(
                title: Text('Enable Child Safety Mode'),
                value: true,
                onChanged: (value) {
                  // Toggle child safety mode
                },
              ),
              ListTile(
                title: Text('Emergency Contact'),
                onTap: () {
                  // Navigate to emergency contact page
                },
              ),
              ListTile(
                title: Text('Report an Incident'),
                onTap: () {
                  // Navigate to report page
                },
              ),
              Divider(),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: Text('Change Password'),
                onTap: () {
                  // Navigate to change password page
                },
              ),
              ListTile(
                title: Text('Log Out'),
                onTap: () {
                  // Log out the user
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
