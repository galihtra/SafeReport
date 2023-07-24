import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:safe_report/model/campaign_model.dart';
import 'package:safe_report/model/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:safe_report/screens/kampanye_notif.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ListKampanye extends StatefulWidget {
  @override
  _ListKampanyeState createState() => _ListKampanyeState();
}

class _ListKampanyeState extends State<ListKampanye> {
  String _filter = 'Semua Kategori';
  bool _isDescending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Semua Kampanye",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0), // Radius
                color: Colors.white,
                border:
                    Border.all(color: Color(0xFF667085), width: 0.5), // Border
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _filter,
                  style: GoogleFonts.inter(
                    color: Color(0xFF667085),
                  ),
                  items: <String>[
                    'Semua Kategori',
                    'kampanye jangka panjang',
                    'kampanye mendatang',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _filter = newValue!;
                      _isDescending =
                          newValue == 'kampanye jangka panjang' ? true : false;
                    });
                  },
                  dropdownColor: Colors.white,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('campaigns')
                  .orderBy('dateTime', descending: _isDescending)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> campaignDocs =
                      snapshot.data!.docs;
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
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 15, left: 15, bottom: 15),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                if (campaign.imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      campaign.imageUrl,
                                      fit: BoxFit.cover,
                                      height: 120,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15, bottom: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        campaign.title,
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
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
                                                        campaign.dateTime
                                                            .toDate()) +
                                                    ' WIB',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255, 33, 33, 33),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 25,
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
                                                DateFormat('dd MMMM yyyy')
                                                    .format(campaign.dateTime
                                                        .toDate()),
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
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        campaign.description.length > 150
                                            ? '${campaign.description.substring(0, 150)}...'
                                            : campaign.description,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Color(0xFF667085),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Divider(
                                        color: Colors.black,
                                        thickness: 0.1,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Pemateri:",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Color(0xFF667085),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        campaign.nameSpeaker,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Tempat",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Color(0xFF667085),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        campaign.place,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 28,
                                            width: 65,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF4E8EA),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Center(
                                              child: Text(
                                                campaign.meet,
                                                style: GoogleFonts.inter(
                                                  color: Color(0xFFEC407A),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            height: 40,
                                            width: 130,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFEC407A),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Gabung",
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Terjadi kesalahan"),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Halaman Detail User
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
                  backgroundColor: Color.fromARGB(255, 238, 236, 236),
                  radius: 30,
                  child: Icon(
                    Icons.campaign,
                    color: Color(0xFFEC407A),
                    size: 30,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Anda yakin ingin \nbergabung kampanye ini?',
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

        // Tampilkan dialog kalau berhasil bergabung
        Alert(
          context: context,
          type: AlertType.success,
          title: "BERHASIL BERGABUNG",
          desc: "Anda telah berhasil bergabung dalam kampanye.",
          buttons: [
            DialogButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                // Tutup dialog dan navigasi ke halaman KampanyeNotif setelah mengklik 'OK'
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => KampanyeNotif(),
                  ),
                );
              },
              width: 120,
            )
          ],
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(''),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: size.height,
            child: Stack(
              children: [
                Container(
                  height: size.height * 0.35,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: (widget.campaign.imageUrl != null)
                          ? NetworkImage(widget.campaign.imageUrl!)
                              as ImageProvider
                          : AssetImage('assets/images/default_avatar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: size.height * 0.75,
                    width: size.width,
                    margin: EdgeInsets.only(top: size.height * 0.3),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 10,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            widget.campaign.title,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF263257),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.campaign.description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF667085),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Pemateri',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF263257),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.campaign.nameSpeaker,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF667085),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Jam & Tanggal',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF263257),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                DateFormat('HH:mm').format(
                                        widget.campaign.dateTime.toDate()) +
                                    ' WIB',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF667085),
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: Color(0xFFEC407A),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                DateFormat('dd MMMM yyyy')
                                    .format(widget.campaign.dateTime.toDate()),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF667085),
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.date_range,
                                size: 20,
                                color: Color(0xFFEC407A),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Tempat',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF263257),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.campaign.place,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF667085),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Peserta yang mengikuti',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF263257),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 20,
                                color: Color(0xFFEC407A),
                              ),
                              SizedBox(width: 5),
                              Text(
                                widget.campaign.participants.length.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF667085),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: isJoined ? null : joinCampaign,
                            child: Text(
                              isJoined ? 'Sudah Bergabung' : 'Bergabung',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(350, 55)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.green;
                                  }
                                  return Color(
                                      0xFFEC407A); // Use the component's default.
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
