import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/authentication/controllers/account_controller.dart';
import 'package:guardiancare/src/screens/emergencyContactPage.dart';
import 'package:guardiancare/src/screens/reportPage.dart';

class Account extends StatelessWidget {
  final User? user;

  const Account({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child:
                    user?.displayName != null && user!.displayName!.isNotEmpty
                        ? Text(user!.displayName![0].toUpperCase())
                        : null,
              ),
              const SizedBox(height: 10),
              const Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('Name: ${user?.displayName ?? 'Not available'}'),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text('Email: ${user?.email ?? 'Not available'}'),
              ),
              const Divider(),
              const Text(
                'Child Safety Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: const Text('Emergency Contact'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmergencyContactPage(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Report an Incident'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportPage(),
                    ),
                  );
                },
              ),
              const Divider(),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: const Text('Log Out'),
                onTap: () async {
                  await AccountController.signOut(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
