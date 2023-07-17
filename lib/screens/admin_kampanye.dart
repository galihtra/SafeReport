import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminKampanye extends StatelessWidget {
  const AdminKampanye({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Kampanye Terbuat",
          style: GoogleFonts.inter(
              color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
    );
  }
}
