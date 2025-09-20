import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/authentication/authentication.dart';
import 'package:guardiancare/src/features/profile/profile.dart';
import 'package:guardiancare/src/features/emergency/screens/emergency_contact_page.dart';

class Account extends StatefulWidget {
  final User? user;

  const Account({super.key, this.user});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  void initState() {
    super.initState();
    // Load user profile when screen initializes
    if (widget.user != null) {
      context.read<ProfileBloc>().add(ProfileLoadRequested(widget.user!.uid));
    }
  }

  void _confirmAndDeleteAccount() {
    final profileBloc = context.read<ProfileBloc>();
    
    showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account',
              style:
                  TextStyle(color: tPrimaryColor, fontWeight: FontWeight.bold)),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User clicked "No"
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User clicked "Yes"
              },
              style: TextButton.styleFrom(
                foregroundColor: tPrimaryColor, // Sets the text color
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((shouldDelete) {
      if (shouldDelete == true) {
        // Trigger account deletion through BLoC
        profileBloc.add(const ProfileDeleteAccountRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileSignedOut) {
                // Navigate to login and clear navigation stack
                context.read<AuthenticationBloc>().add(const AuthenticationSignOutRequested());
              } else if (state is ProfileAccountDeleted) {
                // Navigate to login and clear navigation stack
                context.read<AuthenticationBloc>().add(const AuthenticationSignOutRequested());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted successfully')),
                );
              } else if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileSigningOut) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileDeletingAccount) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Deleting account...'),
                    SizedBox(height: 8),
                    Text(
                      'This may take a few moments',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else if (state is ProfileLoaded) {
              final profile = state.profile;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profile.photoURL != null
                            ? NetworkImage(profile.photoURL!)
                            : null,
                        child: profile.photoURL == null
                            ? Text(
                                profile.initials,
                                style: const TextStyle(fontSize: 24),
                              )
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
                      ListTile(
                        leading: const Icon(Icons.person, color: tPrimaryColor),
                        title: Text('Name: ${profile.displayName}'),
                      ),
                      ListTile(
                        minTileHeight: 5,
                        leading: const Icon(Icons.email, color: tPrimaryColor),
                        title: Text('Email: ${profile.email}'),
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
                        onTap: () {
                          context.read<ProfileBloc>().add(const ProfileSignOutRequested());
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
                        onTap: () {
                          // Trigger the confirmation and deletion logic
                          _confirmAndDeleteAccount();
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.user != null) {
                          context.read<ProfileBloc>().add(
                            ProfileLoadRequested(widget.user!.uid),
                          );
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            // Default case
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
