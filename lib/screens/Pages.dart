import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/account.dart';
import 'package:myapp/screens/forumPage.dart';
import 'package:myapp/screens/homePage.dart';
import 'package:myapp/screens/reportPage.dart';
import 'package:myapp/screens/searchPage.dart';

class Pages extends StatefulWidget {
  const Pages({Key? key}) : super(key: key);

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int index = 2; // Changed the default index value
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
        Icons.search,
        size: 20,
        color: Colors.amber,
      ),
      const Icon(
        Icons.report,
        size: 20,
        color: Colors.amber,
      ),
      const Icon(
        Icons.home,
        size: 20,
        color: Colors.amber,
      ),
      const Icon(
        Icons.forum,
        size: 20,
        color: Colors.amber,
      ),
      const Icon(
        Icons.account_circle,
        size: 20,
        color: Colors.amber,
      ),
    ];

    final screens = <Widget>[
      SearchPage(),
      ReportPage(),
      const HomePage(),
      ForumPage(),
      Account(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text("Guardian Care"),
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
        color: Colors.blue,
        height: 60,
        index: index,
        onTap: (index) => setState(() {
          this.index = index;
        }),
      ),
    );
  }

  Widget _signOut() {
    return TextButton(
        onPressed: () => _auth.signOut(), child: const Text("Sign Out"));
  }
}
