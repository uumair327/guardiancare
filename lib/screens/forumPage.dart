import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
          child: Center(
              child: Text(
        "forum Page",
      ))),
    );
  }
}
