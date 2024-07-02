// loggedOut
// loggedIn

import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/authentication/screens/loginPage.dart';
import 'package:guardiancare/src/features/home/screens/homePage.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginPage()),
});

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: HomePage()),
  },
);
