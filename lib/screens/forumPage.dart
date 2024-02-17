import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      body: SafeArea(
          child: Center(
              child: Text(
        "Forum Page",
      ))),
    );
  }
}
