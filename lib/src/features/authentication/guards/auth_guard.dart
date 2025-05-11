import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiancare/src/features/authentication/controllers/login_controller.dart';
import 'package:guardiancare/src/features/authentication/screens/login_page.dart';

class AuthGuard extends GetMiddleware {
  final AuthService _authService = AuthService();

  @override
  RouteSettings? redirect(String? route) {
    if (_authService.getCurrentUser() == null) {
      return const RouteSettings(
        name: '/login',
        arguments: {'requireLogin': true},
      );
    }
    return null;
  }
}

class ParentalGuard extends GetMiddleware {
  final AuthService _authService = AuthService();

  @override
  RouteSettings? redirect(String? route) {
    if (_authService.isGuestUser()) {
      return const RouteSettings(
        name: '/login',
        arguments: {
          'requireLogin': true,
          'message': 'This feature requires a registered account',
        },
      );
    }
    return null;
  }
}
