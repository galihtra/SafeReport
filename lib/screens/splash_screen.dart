import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:safe_report/screens/signin_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen(this.color ,{super.key});

  final color;

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Get.to(const SignInScreen());
    });
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
