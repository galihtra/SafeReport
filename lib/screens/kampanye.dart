import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/model/campaign_model.dart';
import 'package:safe_report/model/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AdminKampanye extends StatefulWidget {
  const AdminKampanye({Key? key});

  @override
  _AdminKampanyeState createState() => _AdminKampanyeState();
}

class _AdminKampanyeState extends State<AdminKampanye> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  File? _selectedImage;

  void _buatKampanye() async {
    final String judul = _judulController.text;
    final String deskripsi = _deskripsiController.text;

    final User? user = FirebaseAuth.instance.currentUser;
    final String adminId = user?.uid ?? '';

    // Path lokal file gambar
    File imageFile = _selectedImage!;

    if (imageFile != null) {
      final String imageName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('campaign_images')
          .child(imageName);

      final TaskSnapshot taskSnapshot =
          await storageReference.putFile(imageFile);
      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      final Campaign newCampaign = Campaign(
        id: '',
        title: judul,
        description: deskripsi,
        adminId: adminId,
        participants: [],
        imageUrl: imageUrl,
      );

      final CollectionReference campaignsRef =
          FirebaseFirestore.instance.collection('campaigns');

      final DocumentReference docRef =
          await campaignsRef.add(newCampaign.toJson());
      final String campaignId = docRef.id;

      newCampaign.id = campaignId;
      await docRef.update({'id': campaignId});

      Navigator.pop(context);
    }
  }

  Future<void> _ambilGambar() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
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
            Text(
              'Pilih Gambar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: _ambilGambar,
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey,
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                    ),
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

class ListKampanye extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "List Kampanye",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('campaigns').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot> campaignDocs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: campaignDocs.length,
              itemBuilder: (context, index) {
                final Campaign campaign =
                    Campaign.fromSnapshot(campaignDocs[index]);
                return ListTile(
                  title: Text(campaign.title),
                  subtitle: Text(campaign.description),
                  leading: campaign.imageUrl.isNotEmpty
                      ? Image.network(
                          campaign.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : null,
                  trailing: ElevatedButton(
                    onPressed: () => _joinKampanye(context, campaign.id),
                    child: Text('Bergabung'),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _joinKampanye(BuildContext context, String campaignId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User belum login, lakukan penanganan sesuai kebutuhan aplikasi
      return;
    }

    final String userId = user.uid;

    final DocumentReference campaignRef =
        FirebaseFirestore.instance.collection('campaigns').doc(campaignId);

    final DocumentSnapshot campaignSnapshot = await campaignRef.get();

    if (campaignSnapshot.exists) {
      final Campaign campaign = Campaign.fromSnapshot(campaignSnapshot);

      if (campaign.participants
          .any((participant) => participant.uid == userId)) {
        // Pengguna sudah bergabung dalam kampanye
        return;
      }

      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        final UserModel userModel =
            UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);
        campaign.participants.add(userModel);
        campaignRef.update({
          'participants':
              campaign.participants.map((user) => user.toMap()).toList()
        });
      }
    }

    // Tambahkan logika untuk pengiriman sertifikat oleh admin jika diperlukan

    Navigator.pop(
        context); // Kembali ke halaman sebelumnya setelah bergabung dalam kampanye
  }
}
