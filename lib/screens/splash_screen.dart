import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:safe_report/screens/signin_screen.dart';
import 'package:safe_report/screens/navigation_bar.dart'; // Pastikan untuk mengimpor file Home Screen Anda di sini

class SplashScreen extends StatelessWidget {
  const SplashScreen(this.color, {super.key});

  final color;

  Future<void> checkUserStatus() async {
    // Cek apakah ada user yang sudah masuk sebelumnya
    var user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 3));

    if (user != null) {
      // Jika user sudah masuk sebelumnya, langsung navigasi ke Home Screen
      Get.offAll(() => BarNavigation());
    } else {
      // Jika belum ada user yang masuk, navigasi ke Sign In Screen
      Get.offAll(() => const SignInScreen());
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
