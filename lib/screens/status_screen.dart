import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';


void main() {
  runApp(Status());
}

class Status extends StatefulWidget {
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  final List<String> imageAssets = [
    'assets/images/Vector_nonactive.png',
    'assets/images/Check_nonactive.png',
    'assets/images/pelaporan_logo.png',
    'assets/images/Proses_nonactive.png',
    'assets/images/Done all_nonactive.png',
  ];

  final List<String> textList = [
    "Laporan Terkirim oleh Laura - Sabtu 29 April 2023 - 12:38 Siang",
    "diproses...",
    "diproses...",
    "diproses...",
    "Laporan Berhasil",
  ];

  final List<String> descList = [
    "Kekerasan Seksual",
    "diproses...",
    "diproses...",
    "diproses...",
    "Selesai...",
  ];

  // Add the Firebase Auth instance to access the user's UID
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to fetch the user's name with isAdmin == true from the "users" collection
 Future<String?> getAdminName(String userUID) async {
  String? adminName;
  try {
    var reportSnapshot = await FirebaseFirestore.instance
        .collection('report')
        .where('uid', isEqualTo: userUID)
        .where('status', isEqualTo: 'Accepted')
        .get();

    if (reportSnapshot.docs.isNotEmpty) {
      var adminUID = reportSnapshot.docs.first.get('adminUID');
      var adminSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(adminUID)
          .get();
      adminName = adminSnapshot.get('name');
    }
  } catch (e) {
    print('Error fetching admin name: $e');
  }
  return adminName;
}

  // Function to check if the user has submitted any data or if the report document exists
  Future<bool> hasUserReport(String userUID) async {
    try {
      var reportSnapshot = await FirebaseFirestore.instance
          .collection('report')
          .where('uid', isEqualTo: userUID)
          .get();

      return reportSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user has report: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Status Laporan",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('report').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              var reports = snapshot.data!.docs;
              var userUID = _auth.currentUser!.uid;

              return FutureBuilder<bool>(
                future: hasUserReport(userUID),
                builder: (context, reportSnapshot) {
                  if (reportSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (reportSnapshot.hasError) {
                    return Center(
                      child: Text("Error checking report data."),
                    );
                  } else {
                    var hasReportData = reportSnapshot.data;
                    if (hasReportData == false) {
                      return Center(
                        child: Text("No Report Data"),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: imageAssets.length,
                        itemBuilder: (context, index) {
                  // Check if the user has submitted the data and status is null or "Accepted"
                  if (index == 0 &&
                      reports.any((report) =>
                          report['uid'] == userUID &&
                          (report['status'] == null ||
                              report['status'] == "Accepted"))) {
                    // Change the image for Vector_nonactive.png to Vector_active.png
                    imageAssets[index] = 'assets/images/Vector_active.png';

                    // Get the information from Firestore
                    var userReport = reports.firstWhere((report) =>
                        report['uid'] == userUID &&
                        (report['status'] == null ||
                            report['status'] == "Accepted"));
                    var userName = userReport['nama'];
                    var submissionTime =
                        DateTime.parse(userReport['tanggalKejadian']);
                    var formattedDate =
                        DateFormat('dd MMMM yyyy', 'en_US').format(submissionTime);
                    var cases = userReport['jenisKasus'];
                    var time = userReport['jam'];

                    // Update the textList with the user's name and submission date and time
                    textList[index] =
                        "Laporan Terkirim oleh $userName - $formattedDate $time";

                    descList[index] = cases;

                    return buildActiveItem(index);
                  } else if (index == 1 &&
                      reports.any((report) =>
                          report['uid'] == userUID &&
                          report['status'] == "Accepted")) {
                    // Change the image for Check_nonactive.png to Check_active.png
                    imageAssets[index] = 'assets/images/Check_active.png';

                    // Fetch the admin's name with isAdmin == true from the "users" collection
                    return FutureBuilder<String?>(
                      future: getAdminName(userUID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return buildActiveItem(index); // Placeholder while fetching
                        } else if (snapshot.hasError) {
                          return buildNonActiveItem(index); // Show non-active item on error
                        } else {
                          var adminName = snapshot.data;
                          if (adminName != null) {
                            // Update the textList with the admin's name and submission date
                            var userReport = reports.firstWhere((report) =>
                                report['uid'] == userUID && report['status'] == "Accepted");

                            // Convert the Timestamp object to a DateTime
                            var timestamp = userReport['tanggal_diterima_petugas'] as Timestamp;
                            var submissionTime = timestamp.toDate();
                            var formattedDate = DateFormat('dd MMMM yyyy', 'en_US').format(submissionTime);

                            var formattedTime = DateFormat('HH:mm').format(submissionTime); 

                            textList[index] =
                                "Laporan Diterima oleh $adminName - $formattedDate $formattedTime";
                              
                            descList[index] = "Diterima oleh petugas";
                          }

                          return buildActiveItem(index);
                        }
                      },
                    );
                  } else if (index == 2 &&
                      reports.any((report) =>
                          report['uid'] == userUID &&
                          report['status'] == "Accepted" && report['verification'] == true || report['verification'] == false)) {
                    // Change the image for Check_nonactive.png to Check_active.png
                    imageAssets[index] = 'assets/images/Assignment.png';

                    // Fetch the admin's name with isAdmin == true from the "users" collection
                    return FutureBuilder<String?>(
                      future: getAdminName(userUID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return buildActiveItem(index); // Placeholder while fetching
                        } else if (snapshot.hasError) {
                          return buildNonActiveItem(index); // Show non-active item on error
                        } else {
                          var adminName = snapshot.data;
                          if (adminName != null) {
                            // Update the textList with the admin's name and submission date
                            var userReport = reports.firstWhere((report) =>
                                report['uid'] == userUID && report['status'] == "Accepted");

                            // Convert the Timestamp object to a DateTime
                            var timestamp = userReport['tanggal_diterima_petugas'] as Timestamp;
                            var submissionTime = timestamp.toDate();
                            var formattedDate = DateFormat('dd MMMM yyyy', 'en_US').format(submissionTime);

                            var formattedTime = DateFormat('HH:mm').format(submissionTime); 

                            textList[index] =
                                "Laporan diverifikasi oleh $adminName - $formattedDate $formattedTime";
                              
                            descList[index] = "diverifikasi oleh $adminName";
                          }

                          return buildActiveItem(index);
                        }
                      },
                    );
                  } else if (index == 3 &&
                      reports.any((report) =>
                          report['uid'] == userUID &&
                          report['status'] == "Accepted" &&
                          report['diterima_oleh'] != null && report['verification'] != null && report['verification'] == true)) {

                    imageAssets[index] = 'assets/images/Proses_active.png';

                    // Fetch the admin's name with isAdmin == true from the "users" collection
                    return FutureBuilder<String?>(
                      future: getAdminName(userUID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return buildActiveItem(index); // Placeholder while fetching
                        } else if (snapshot.hasError) {
                          return buildNonActiveItem(index); // Show non-active item on error
                        } else {
                          var adminName = snapshot.data;
                          if (adminName != null) {
                            // Update the textList with the admin's name and submission date
                            var userReport = reports.firstWhere((report) =>
                                report['uid'] == userUID && report['status'] == "Accepted");

                            // Convert the Timestamp object to a DateTime
                            var submissionTime = userReport['tanggal_diterima'];
                            var timestamp = Timestamp.fromDate(DateTime.parse(submissionTime));
                            var dateTime = timestamp.toDate();
                            var formattedDate = DateFormat('dd MMMM yyyy', 'en_US').format(dateTime);
                            var time = userReport['jam_diterima'];
                            var diterima_oleh = userReport['diterima_oleh'];
                            if (diterima_oleh != null && diterima_oleh.length > 50) {
                              diterima_oleh = diterima_oleh.substring(0, 40) + '...';
                            }
                            textList[index] =
                                "$diterima_oleh - $formattedDate $time";
                              
                            descList[index] = "Di proses";
                          }

                          return buildActiveItem(index);
                        }
                      },
                    );
                  } else if (index == 4 &&
                      reports.any((report) =>
                          report['uid'] == userUID &&
                          report['status'] == "Accepted" &&
                          report['diterima_oleh'] != null && report['verification'] != null && report['verification'] == true && report['selesai'] == 'selesai')) {

                    imageAssets[index] = 'assets/images/Proses_active.png';

                    // Fetch the admin's name with isAdmin == true from the "users" collection
                    return FutureBuilder<String?>(
                      future: getAdminName(userUID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return buildActiveItem(index); // Placeholder while fetching
                        } else if (snapshot.hasError) {
                          return buildNonActiveItem(index); // Show non-active item on error
                        } else {
                          var adminName = snapshot.data;
                          var userReport;
                          if (adminName != null) {
                            // Update the textList with the admin's name and submission date
                            var userReport = reports.firstWhere((report) =>
                                report['uid'] == userUID && report['status'] == "Accepted");

                            textList[index] =
                                "Laporan Selesai";
                              
                            descList[index] = "Selesai";
                          }
                          return buildActiveItem(index);
                        }
                      },
                    );
                  } else {
                    return buildNonActiveItem(index);
                  }
                },
              );
              }
              }
            }
          );
          }
        ),
      )
    )
    );
  }

  Widget buildActiveItem(int index) {
  return Container(
    child: Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 3,
              height: 60,
              color: index == 0 ? Colors.transparent : Color(0xFFEC407A),
            ),
            Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(left: 15, right: 10),
              decoration: BoxDecoration(
                color: Color(0xFFEC407A),
                borderRadius: BorderRadius.circular(25), // Adjust the border radius here
                border: Border.all(
                  color: Color(0xFFEC407A),
                ),
              ),
              child: Image.asset(
                imageAssets[index],
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 40), // Adjust top padding here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    textList[index],
                    style: GoogleFonts.inter(
                      fontSize: 14, // Adjust font size here
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    descList[index],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildNonActiveItem(int index) {
  return Container(
    child: Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 3,
              height: 65,
              color: index == 0 ? Colors.transparent : Color(0xFFEC407A),
            ),
            Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(left: 15, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25), // Adjust the border radius here
                border: Border.all(
                  color: Color(0xFFEC407A),
                ),
              ),
              child: Image.asset(
                imageAssets[index],
                width: 30, // Adjust image size here
                height: 30, // Adjust image size here
              ),
            ),
          ],
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 40), // Adjust top padding here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    textList[index],
                    style: GoogleFonts.inter(
                      fontSize: 14, // Adjust font size here
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    descList[index],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}