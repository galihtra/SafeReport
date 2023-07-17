import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Kampanye extends StatelessWidget {
  const Kampanye({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Kampanye Terbaru",
          style: GoogleFonts.inter(
              color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
    );
  }
}
