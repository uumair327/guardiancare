import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiancare/src/features/authentication/controllers/auth_controller.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/authentication/screens/login_page.dart';
import 'package:guardiancare/src/features/emergency/screens/emergency_contact_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Extension to add deleteAccount method to AuthController
extension AuthControllerExtension on AuthController {
  Future<void> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}

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

  Future<void> _clearUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_seen_forum_guidelines');
  }

  Future<void> _confirmAndDeleteAccount(BuildContext context) async {
    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account',
              style:
                  TextStyle(color: tPrimaryColor, fontWeight: FontWeight.bold)),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User clicked "No"
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User clicked "Yes"
              },
              style: TextButton.styleFrom(
                foregroundColor: tPrimaryColor, // Sets the text color
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldDelete) {
      // Show loading indicator for 10 seconds
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Simulate a delay for 10 seconds
      await Future.delayed(const Duration(seconds: 10));

      try {
        // Get the auth controller
        final authController = Get.find<AuthController>();
        
        // Delete the user account
        await authController.deleteAccount();
        
        // Clear user preferences
        await _clearUserPreferences();
        
        // Close the loading indicator
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        
        // Navigate back to the login page after successful deletion
        Get.offAllNamed('/login');
      } catch (e) {
        // Close the loading indicator
        if (context.mounted) {
          Navigator.of(context).pop();
          // Show error message if deletion failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: ${e.toString()}'),
            ),
          );
        }
      }
    }
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
              padding: const EdgeInsets.all(10.0),
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
                    minTileHeight: 5,
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
                          builder: (context) => const EmergencyContactPage(),
                        ),
                      );
                    },
                  ),
                  // ListTile(
                  //   minTileHeight: 5,
                  //   leading: const Icon(Icons.warning, color: tPrimaryColor),
                  //   title: const Text('Report an Incident'),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const ReportPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
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
                      try {
                        await _clearUserPreferences();
                        final authController = Get.find<AuthController>();
                        await authController.signOut();
                        
                        // Navigate to login page using GetX
                        Get.offAllNamed('/login');
                        
                        if (Get.isSnackbarOpen) {
                          Get.back(); // Close any open snackbar
                        }
                        
                        Get.snackbar(
                          'Success',
                          'Signed out successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error signing out: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    minTileHeight: 5,
                    leading: const Icon(Icons.delete, color: tPrimaryColor),
                    title: const Text(
                      'Delete My Account',
                      style: TextStyle(
                          color: tPrimaryColor, fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      // Trigger the confirmation and deletion logic
                      await _confirmAndDeleteAccount(context);
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
