import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/forum/features/auth/screens/login_screen.dart';
import 'package:guardiancare/src/screens/explore.dart';
import 'package:guardiancare/src/screens/homePage.dart';

class Pages extends StatefulWidget {
  const Pages({Key? key}) : super(key: key);

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int index = 0; // Changed the default index value
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(
        Icons.home,
        size: 25,
        color: tNavBarColorButton,
      ),
      // const Icon(
      //   Icons.search,
      //   size: 25,
      //   color: Colors.amber,
      // ),
      const Icon(
        Icons.explore,
        size: 25,
        color: tNavBarColorButton,
      ),
      const Icon(
        Icons.forum,
        size: 25,
        color: tNavBarColorButton,
      ),
      // const Icon(
      //   Icons.account_circle,
      //   size: 25,
      //   color: Colors.amber,
      // ),
    ];

    final screens = <Widget>[
      const HomePage(),
      const Explore(),
      const LoginScreen(),
      // const HomeScreen(),
      // Account(user: _user),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text("Children of India",
            style: TextStyle(
                color: tPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 25)),
        leading: const Padding(
          padding: EdgeInsets.all(13.0),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          _user != null ? _signOut() : const Text("Hi"),
        ],
      ),
      body: SafeArea(
        child: screens[index],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        backgroundColor: Colors.transparent,
        color: tNavBarColor,
        height: 65,
        index: index,
        onTap: (index) => setState(() {
          this.index = index;
        }),
      ),
    );
  }

  Widget _signOut() {
    return TextButton(
        onPressed: () => _auth.signOut(),
        child: const Text("Sign Out", style: TextStyle(color: tPrimaryColor)));
  }
}
