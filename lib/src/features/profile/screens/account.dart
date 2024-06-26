import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/authentication/controllers/auth_controller.dart';
import 'package:guardiancare/src/features/emergency/screens/emergencyContactPage.dart';
import 'package:guardiancare/src/features/report/screens/reportPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Account extends ConsumerWidget {
  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    
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
                leading: const Icon(Icons.person, color: tPrimaryColor),
                title: Text('Name: ${user?.displayName ?? 'Not available'}'),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: tPrimaryColor),
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
                leading: const Icon(Icons.phone, color: tPrimaryColor),
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
                leading: const Icon(Icons.warning, color: tPrimaryColor),
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
                leading: const Icon(Icons.logout, color: tPrimaryColor),
                title: const Text('Log Out'),
                onTap: () => logOut(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
