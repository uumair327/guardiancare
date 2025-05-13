import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiancare/services/auth_service.dart';
import 'package:guardiancare/src/features/authentication/screens/login_page.dart';

class GuestRestrictedWidget extends StatelessWidget {
  final Widget child;
  final String message;

  const GuestRestrictedWidget({
    Key? key,
    required this.child,
    this.message = 'This feature is not available for guest users',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthService>(
      builder: (authService) {
        if (authService.isGuestUser()) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(
                      LoginPage.routeName,
                      arguments: {
                        'requireLogin': true,
                        'message': message,
                      },
                    );
                  },
                  child: const Text('SIGN IN / SIGN UP'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        return child;
      },
    );
  }
}
