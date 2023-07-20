import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_report/model/campaign_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/model/certificate_model.dart';
import 'package:safe_report/model/user_model.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';

class KampanyeNotif extends StatefulWidget {
  const KampanyeNotif({Key? key}) : super(key: key);

  @override
  _KampanyeNotifState createState() => _KampanyeNotifState();
}

class _KampanyeNotifState extends State<KampanyeNotif> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notif Kampanye"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('campaigns').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            List<Campaign> campaigns = snapshot.data!.docs
                .map((doc) => Campaign.fromSnapshot(doc))
                .where((campaign) => campaign.participants
                    .any((user) => user.uid == currentUserId))
                .toList();

            return ListView.builder(
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                Campaign campaign = campaigns[index];

                UserModel currentUser = campaign.participants
                    .firstWhere((user) => user.uid == currentUserId);

                Certificate? campaignCertificate;
                if (currentUser.certificates != null) {
                  campaignCertificate = currentUser.certificates!
                      .firstWhereOrNull((certificate) =>
                          certificate.campaignId == campaign.id);
                }

                return ListTile(
                  title: Text(campaign.title),
                  subtitle: Text(campaign.description),
                  leading: Image.network(campaign.imageUrl),
                  trailing: campaignCertificate == null
                      ? Text('No certificate')
                      : IconButton(
                          icon: Icon(Icons.file_download),
                          onPressed: () =>
                              _launchURL(campaignCertificate!.certificateUrl),
                        ),
                  onTap: () {
                    // Navigasi ke detail kampanye saat di-tap
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
