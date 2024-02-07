import 'package:flutter/material.dart';
import 'package:myapp/screens/homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ucs(title: 'Flutter Demo Home Page'),
    );
  }
}

class ucs extends StatefulWidget {
  const ucs({super.key, required this.title});
  final String title;

  @override
  State<ucs> createState() => _ucsState();
}

class _ucsState extends State<ucs> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Marathon App",
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
