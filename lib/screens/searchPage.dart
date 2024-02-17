import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
          child: Center(
              child: Text(
        "Search PAge",
      ))),
    );
  }
}
