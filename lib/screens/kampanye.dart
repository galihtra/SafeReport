import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/model/campaign_model.dart';
import 'package:safe_report/model/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailKampanye(campaign: campaign),
                      ),
                    );
                  },
                  child: ListTile(
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
}

// Halaman Detail
class DetailKampanye extends StatefulWidget {
  final Campaign campaign;

  DetailKampanye({required this.campaign});

  @override
  _DetailKampanyeState createState() => _DetailKampanyeState();
}

class _DetailKampanyeState extends State<DetailKampanye> {
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    checkIfUserJoined();
  }

  void checkIfUserJoined() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;

      final DocumentSnapshot campaignSnapshot = await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(widget.campaign.id)
          .get();

      if (campaignSnapshot.exists) {
        final Campaign campaign = Campaign.fromSnapshot(campaignSnapshot);

        if (campaign.participants
            .any((participant) => participant.uid == userId)) {
          setState(() {
            isJoined = true;
          });
        }
      }
    }
  }

  void joinCampaign() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 30,
                  child: Icon(
                    Icons.calendar_month,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Anda yakin ingin bergabung dengan kampanye ini?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 100,
                        height: 45,
                        child: ElevatedButton(
                          child: Text(
                            'Batal',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFF1F1F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: SizedBox(
                        width: 100,
                        height: 45,
                        child: ElevatedButton(
                          child: Text(
                            'Yakin',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _proceedToJoinCampaign(user);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFEC407A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _proceedToJoinCampaign(User user) async {
    final String userId = user.uid;

    final DocumentReference campaignRef = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(widget.campaign.id);

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

        setState(() {
          isJoined = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campaign.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.campaign.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Image.network(widget.campaign.imageUrl),
            SizedBox(height: 16),
            Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.campaign.description),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isJoined ? null : joinCampaign,
              child: Text(
                isJoined ? 'Sudah Bergabung' : 'Bergabung',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.green;
                    }
                    return Colors.blue; // Use the component's default.
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
