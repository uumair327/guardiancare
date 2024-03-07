import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Account extends StatelessWidget {
  final User? user;

  const Account({Key? key, this.user}) : super(key: key);

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
              CircleAvatar(
                radius: 50,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null, // Use user's profile picture if available
                child: user?.displayName != null &&
                        user!.displayName!.isNotEmpty
                    ? Text(user!.displayName![0].toUpperCase())
                    : null, // Display user's initials if displayName is available
              ),
              SizedBox(height: 10),
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
                title: Text('Name: ${user?.displayName ?? 'Not available'}'),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email: ${user?.email ?? 'Not available'}'),
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
                value: true, // Replace with actual value from Firebase
                onChanged: (value) {
                  // Update child safety mode in Firebase
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
