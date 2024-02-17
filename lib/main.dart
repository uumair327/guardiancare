import 'package:flutter/material.dart';
import 'package:myapp/screens/homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
        // Consider replacing the line above with 'primarySwatch' to match Material Design guidelines.
        // 'useMaterial3' has been removed in newer Flutter versions.
      ),
      home: UCS(title: 'Home Page'),
    );
  }
}

class UCS extends StatefulWidget {
  const UCS({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<UCS> createState() => _UCSState();
}

class _UCSState extends State<UCS> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: Text('Open Home Page'),
        ),
      ),
    );
  }
}
