import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/model/campaign_model.dart';

class AdminKampanye extends StatefulWidget {
  const AdminKampanye({Key? key});

  @override
  _AdminKampanyeState createState() => _AdminKampanyeState();
}

class _AdminKampanyeState extends State<AdminKampanye> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  void _buatKampanye() async {
    final String judul = _judulController.text;
    final String deskripsi = _deskripsiController.text;

    final User? user = FirebaseAuth.instance.currentUser;
    final String adminId =
        user?.uid ?? ''; // Mengambil adminId dari pengguna yang sedang masuk

    final Campaign newCampaign = Campaign(
      id: '', // ID kampanye akan diisi oleh Firestore
      title: judul,
      description: deskripsi,
      adminId: adminId,
      participants: [], // Kampanye baru belum memiliki partisipan
    );

    final CollectionReference campaignsRef =
        FirebaseFirestore.instance.collection('campaigns');

    final DocumentReference docRef =
        await campaignsRef.add(newCampaign.toJson());
    final String campaignId = docRef.id;

    newCampaign.id = campaignId;
    await docRef.update({'id': campaignId});

    Navigator.pop(
        context); // Kembali ke halaman sebelumnya setelah kampanye dibuat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Buat Kampanye",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Judul',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _judulController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul kampanye',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _deskripsiController,
              decoration: InputDecoration(
                hintText: 'Masukkan deskripsi kampanye',
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buatKampanye,
              child: Text('Buat Kampanye'),
            ),
          ],
        ),
      ),
    );
  }
}
