import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/model/campaign_model.dart';
import 'package:safe_report/model/user_model.dart';

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
                final Campaign campaign = Campaign.fromSnapshot(campaignDocs[index]);
                return ListTile(
                  title: Text(campaign.title),
                  subtitle: Text(campaign.description),
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
