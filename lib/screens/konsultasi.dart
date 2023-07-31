import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_report/model/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class Konsultasi extends StatefulWidget {
  const Konsultasi({Key? key}) : super(key: key);

  @override
  _KonsultasiState createState() => _KonsultasiState();
}

class _KonsultasiState extends State<Konsultasi> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('08')) {
      return '+62${phoneNumber.substring(1)}';
    }
    return phoneNumber;
  }

  void _launchWhatsApp(String phoneNumber) async {
    final formattedPhoneNumber = _formatPhoneNumber(phoneNumber);
    String whatsappUrl = "whatsapp://send?phone=$formattedPhoneNumber";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Tidak dapat membuka WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Konselor",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('isAdmin', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                UserModel user = UserModel.fromMap(data);
                return InkWell(
                  onTap: () {
                    final String phoneNumber = user.no_telp ?? '';
                    // Navigasi ke wa
                    _launchWhatsApp(
                        '$phoneNumber'); // Ganti nomor WhatsApp admin dengan nomor yang benar
                  },
                  child: ListTile(
                    leading: (user.image_url != null)
                        ? CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(user.image_url!),
                          )
                        : CircleAvatar(
                            radius: 25,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            backgroundColor: Color(0xFFEC407A),
                          ),
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 1),
                      child: Text(
                        user.name,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text(
                            user.gender,
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            '(${user.prodi ?? ''})',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF98A2B3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 26,
                        width: 60,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFFEC407A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Chat",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}