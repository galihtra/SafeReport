import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_report/screens/status_screen.dart';
import 'package:safe_report/screens/navigation_bar.dart';

class ReportSuccess extends StatelessWidget {
  const ReportSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 24), // Added margin
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/cecklis.png',
                width: 220,
              ),
              Text(
                'Laporan telah dibuat',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Color(0xFF151522),
                  fontSize: 28,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Laporan Anda sedang kami tinjau. Jika Anda membutuhkan bantuan lebih lanjut seperti layanan psikologi atau pendampingan, silahkan gunakan fitur yang tersedia di aplikasi kami. Jangan ragu untuk memberitahu kami jika Anda mengalami trauma atau masalah serius lainnya. ',
                textAlign: TextAlign.justify,
                style: GoogleFonts.inter(
                  color: Color(0xFF999999),
                  fontSize: 12,
                  height: 2.2,
                ),
              ),
              SizedBox(height: 120.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BarNavigation(currentIndex: 1)),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(left: 30, right: 30, top: 14, bottom: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Color(0xFFEC407A),
                  ),
                  child: Text(
                    'PANTAU STATUS LAPORAN',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
