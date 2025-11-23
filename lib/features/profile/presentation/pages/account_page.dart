import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/di/injection_container.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_event.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_event.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_state.dart';
import 'package:guardiancare/core/constants/app_colors.dart';

class AccountPage extends StatelessWidget {
  final User? user;

  const AccountPage({super.key, this.user});

  Future<void> _confirmAndDeleteAccount(
      BuildContext context, ProfileBloc profileBloc) async {
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
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: tPrimaryColor,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldDelete && user != null) {
      profileBloc.add(DeleteAccountRequested(user!.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
        ),
        body: const Center(
          child: Text('No user is currently signed in'),
        ),
      );
    }

    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(LoadProfile(user!.uid)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is AccountDeleted) {
              // Navigate to login page after successful deletion
              context.go('/login');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deleted successfully')),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is AccountDeleting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError && state is! AccountDeleting) {
              return Center(child: Text("Error: ${state.message}"));
            }

            if (state is ProfileLoaded) {
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
                        child: profile.displayName.isNotEmpty
                            ? Text(profile.displayName[0].toUpperCase())
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
                        leading:
                            const Icon(Icons.person, color: tPrimaryColor),
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
                        onTap: () => context.push('/emergency'),
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
                          // Show confirmation dialog
                          bool shouldLogout = await showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Log Out',
                                    style: TextStyle(
                                        color: tPrimaryColor,
                                        fontWeight: FontWeight.bold)),
                                content: const Text(
                                    'Are you sure you want to log out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(false);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: tPrimaryColor,
                                    ),
                                    child: const Text('Log Out'),
                                  ),
                                ],
                              );
                            },
                          ) ?? false;

                          if (shouldLogout && context.mounted) {
                            // Clear preferences
                            context
                                .read<ProfileBloc>()
                                .add(const ClearPreferencesRequested());

                            // Sign out using AuthBloc - this will trigger auth state change
                            context.read<AuthBloc>().add(SignOutRequested());
                            
                            // Navigate to login page and remove all previous routes
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                      ),
                      ListTile(
                        minTileHeight: 5,
                        leading: const Icon(Icons.delete, color: tPrimaryColor),
                        title: const Text(
                          'Delete My Account',
                          style: TextStyle(
                              color: tPrimaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () async {
                          await _confirmAndDeleteAccount(
                            context,
                            context.read<ProfileBloc>(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text("Loading profile..."));
          },
        ),
      ),
    );
  }
}
