import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:safe_report/model/campaign_model.dart';
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

  bool isAppointmentExpired(DateTime dateTime) {
    final now = DateTime.now();
    return now.isAfter(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kampanye Saya",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
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

            // Sort campaigns by expired status
            campaigns.sort((a, b) =>
                (isAppointmentExpired(a.dateTime.toDate()) ? 1 : 0).compareTo(
                    (isAppointmentExpired(b.dateTime.toDate()) ? 1 : 0)));

            return ListView.builder(
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                Campaign campaign = campaigns[index];
                final bool isExpired =
                    isAppointmentExpired(campaign.dateTime.toDate());

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      UserModel currentUser =
                          UserModel.fromSnapshot(snapshot.data!);

                      Certificate? campaignCertificate;
                      if (currentUser.certificates != null) {
                        campaignCertificate = currentUser.certificates!
                            .firstWhereOrNull((certificate) =>
                                certificate.campaignId == campaign.id &&
                                certificate.id.isNotEmpty);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                            right: 10, left: 10, top: 10, bottom: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Kampanye",
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Color(0xFFEC407A),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    if (isExpired)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Selesai',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  campaign.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          DateFormat('HH:mm').format(
                                                  campaign.dateTime.toDate()) +
                                              ' WIB',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Color.fromARGB(255, 33, 33, 33),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.date_range,
                                          size: 14,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          DateFormat('dd MMMM yyyy').format(
                                              campaign.dateTime.toDate()),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Detail Tempat:",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  campaign.place,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                                SizedBox(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (campaign.zoomLink != null &&
                                            campaign.zoomLink != "")
                                          ElevatedButton.icon(
                                            icon: Icon(Icons.video_call,
                                                color: Colors.white),
                                            label: Text('Join Zoom',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            onPressed: () =>
                                                _launchURL(campaign.zoomLink!),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Color(0xFFEC407A)),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20))),
                                            ),
                                          )
                                        else
                                          ElevatedButton.icon(
                                            icon: Icon(Icons.video_call,
                                                color: Colors.black),
                                            label: Text('Join Zoom',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            onPressed: null, // Disabled button
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      Color.fromARGB(
                                                          255, 227, 225, 225)),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20))),
                                            ),
                                          ),
                                        Visibility(
                                          visible: campaignCertificate != null,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton.icon(
                                              icon: Icon(Icons.file_download),
                                              label: Text('Unduh Sertifikat'),
                                              onPressed:
                                                  campaignCertificate != null
                                                      ? () => _launchURL(
                                                          campaignCertificate!
                                                              .certificateUrl)
                                                      : null,
                                              style: ElevatedButton.styleFrom(
                                                primary: Color(0xFF4CAF50),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                          replacement: Padding(
                                            padding: const EdgeInsets.all(30.0),
                                            child: Text(
                                              'No certificate',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _launchURL(String? url) async {
    if (url == null || url == '') {
      print('Cannot launch URL: URL is not provided or empty');
      return;
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
