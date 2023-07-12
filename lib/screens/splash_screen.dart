import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:safe_report/screens/signin_screen.dart';
import 'package:safe_report/screens/navigation_bar.dart'; // Pastikan untuk mengimpor file Home Screen Anda di sini
import 'package:safe_report/screens/admin_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen(this.color, {super.key});

  final color;

  Future<void> checkUserStatus() async {
    // Cek apakah ada user yang sudah masuk sebelumnya
    var user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 3));

    if (user != null) {
      // User is logged in, check admin status
      // User is logged in, check admin status
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

      bool isAdmin = userSnapshot.data()?['isAdmin'] ?? false;
      if (isAdmin) {
        // Navigate to the admin home screen
        Get.offAll(() => AdminNavigationBar());
      } else {
        // Navigate to the user home screen
        Get.offAll(() => BarNavigation(currentIndex: 0,));
      }
    } else {
      // No user logged in, navigate to the sign-in screen
      Get.offAll(() => SignInScreen());
    } 
}

  @override
  Widget build(BuildContext context) {
    checkUserStatus();
    return Scaffold(
      body: Container(
        color: color,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo1.png',
                width: 270,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'KESETARAAN GENDER DAN PENCEGAHAN KEKERASAN SEKSUAL DI KAMPUS',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
