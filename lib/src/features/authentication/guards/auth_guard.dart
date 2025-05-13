import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiancare/src/features/authentication/controllers/auth_service.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (authService.getCurrentUser() == null) {
      return const RouteSettings(
        name: '/login',
        arguments: {'requireLogin': true},
      );
    }
    return null;
  }
}

class ParentalGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (authService.getCurrentUser()?.isAnonymous ?? true) {
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
