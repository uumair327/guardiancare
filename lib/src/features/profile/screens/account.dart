import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardianscare/src/constants/colors.dart';
import 'package:guardianscare/src/features/authentication/screens/loginPage.dart';
import 'package:guardianscare/src/features/emergency/screens/emergencyContactPage.dart';
import 'package:guardianscare/src/features/report/screens/reportPage.dart';
import 'package:guardianscare/src/features/authentication/controllers/login_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Account extends StatelessWidget {
  final User? user;

  const Account({super.key, this.user});

  Future<DocumentSnapshot> getUserDetails() async {
    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
    }

    throw Exception("User is null");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getUserDetails(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found"));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userData['photoURL'] != null
                        ? NetworkImage(userData['photoURL'])
                        : null,
                    child: userData['displayName'] != null &&
                            userData['displayName'].isNotEmpty
                        ? Text(userData['displayName'][0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                  // const SizedBox(height: 5),
                  ListTile(
                    leading: const Icon(Icons.person, color: tPrimaryColor),
                    title: Text(
                        'Name: ${userData['displayName'] ?? 'Not available'}'),
                  ),
                  ListTile(
                    minTileHeight: 25,
                    leading: const Icon(Icons.email, color: tPrimaryColor),
                    title:
                        Text('Email: ${userData['email'] ?? 'Not available'}'),
                  ),
                  const Divider(),
                  const SizedBox(height: 5),
                  const Text(
                    'Child Safety Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
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
                    minTileHeight: 25,
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
                  const SizedBox(height: 5),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: tPrimaryColor),
                    title: const Text('Log Out'),
                    onTap: () async {
                      bool result = await signOutFromGoogle();
                      print(result);

                      Navigator.pop(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );

                      if (result) print("Signed Out Successfully !!");
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
