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
  final pages = [
    HomeScreen(),
    Status(),
    Notifications(),
    Profile()
  ];

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'status'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'notif'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'profile'
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}