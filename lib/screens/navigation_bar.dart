import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/screens/home_screen.dart';
import 'package:safe_report/screens/status_screen.dart';
import 'package:safe_report/screens/notifications_screen.dart';
import 'package:safe_report/screens/profile_screen.dart';

class BarNavigation extends StatefulWidget {
  const BarNavigation({Key? key}) : super(key: key);

  @override
  _NavigationBar createState() => _NavigationBar();

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    } else {
      throw ("No user logged in");
    }
  }
}

class _NavigationBar extends State<BarNavigation> {
  int _currentIndex = 0;
  final pages = [HomeScreen(), Status(), Notifications(), Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: new BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            new BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: new Image.asset('assets/images/home.png'),
              activeIcon: new Image.asset('assets/images/home_active.png'),
              label: '',
            ),
            new BottomNavigationBarItem(
              icon: new Image.asset('assets/images/status.png'),
              activeIcon: new Image.asset('assets/images/status_active.png'),
              label: '',
            ),
            new BottomNavigationBarItem(
              icon: new Image.asset('assets/images/notif.png'),
              activeIcon: new Image.asset('assets/images/notif_active.png'),
              label: '',
            ),
            new BottomNavigationBarItem(
              icon: new Image.asset('assets/images/user.png'),
              activeIcon: new Image.asset('assets/images/user_active.png'),
              label: '',
            )
          ]),
    );
  }
}
