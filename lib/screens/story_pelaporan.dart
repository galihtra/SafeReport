import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StoryPelaporanUser extends StatefulWidget {
  @override
  _StoryPelaporanUserState createState() => _StoryPelaporanUserState();
}

class _StoryPelaporanUserState extends State<StoryPelaporanUser> {
  final CollectionReference<Map<String, dynamic>> _reportsCollection =
      FirebaseFirestore.instance.collection('complete_reports');

  // Get the current user's UID using firebase_auth package
  String? _currentUserUid;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUid();
  }

  // Method to get the current user's UID
  Future<void> _getCurrentUserUid() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserUid = currentUser.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History",
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _reportsCollection
            .where('uid',
                isEqualTo: _currentUserUid) // Check for the user's UID
            .where('selesai', isEqualTo: 'selesai')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error fetching data"),
            );
          } else {
            final reports = snapshot.data?.docs ?? [];

            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index].data();
                final reportId = reports[index].id; // Get the report ID

                // Extract the relevant information from the report
                final buktiKejadian = report['bukti_pendukung'] as String;
                final jenisKasus = report['jenis_kasus'] as String;
                final bentukKasus = report['bentuk_kasus'] as String;
                final tanggalKejadian = report['tanggal_kejadian'] as String;
                // Replace "No Date" with your preferred default value
                final jam = report['jam'] as String;
                final nim = report['nim'] as String;
                final nama = report['nama'] as String;
                final prodi = report['prodi'] as String;
                final gender = report['gender'] as String;
                final isReviewSubmitted = report['isReviewSubmitted'] as bool;

                return ReportCard(
                  buktiKejadian: buktiKejadian,
                  jenisKasus: jenisKasus,
                  bentukKasus: bentukKasus,
                  tanggalKejadian: tanggalKejadian,
                  name: nama,
                  prodi: prodi,
                  gender: gender,
                  jam: jam,
                  nim: nim,
                  isReviewSubmitted: isReviewSubmitted,
                  // Pass the report ID to the ReportCard widget
                  reportId: reportId,
                  // Pass the function reference to the ReportCard widget
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ReportCard extends StatefulWidget {
  final String buktiKejadian;
  final String jenisKasus;
  final String tanggalKejadian;
  final String bentukKasus;
  final String name;
  final String gender;
  final String prodi;
  final String jam;
  final String nim;
  final bool isReviewSubmitted;
  final String reportId;

  ReportCard({
    required this.buktiKejadian,
    required this.jenisKasus,
    required this.tanggalKejadian,
    required this.bentukKasus,
    required this.name,
    required this.gender,
    required this.prodi,
    required this.jam,
    required this.nim,
    required this.isReviewSubmitted,
    required this.reportId,
  });

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  double _rating = 0.0;
  String _comment = '';

  String getCurrentUserUid() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ??
        ''; // Return empty string if the user is not authenticated
  }

  @override
  Widget build(BuildContext context) {
    final formattedTanggalKejadian = DateFormat('dd MMMM yyyy')
        .format(DateTime.parse(widget.tanggalKejadian));

    return Card(
      margin: EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.bentukKasus,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEC407A),
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.isReviewSubmitted ? 'Selesai' : 'Selesai',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.buktiKejadian != null
                        ? Image.network(
                            widget.buktiKejadian,
                            fit: BoxFit.cover,
                            height: 65.0,
                            width: 70.0,
                          )
                        : Image.asset(
                            'assets/images/default_avatar.png',
                            fit: BoxFit.cover,
                            height: 65.0,
                            width: 70.0,
                          ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.gender,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          widget.prodi,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF98A2B3)),
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.jam,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedTanggalKejadian,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: widget.isReviewSubmitted
                      ? null
                      : () {
                          // Implement the logic for the "Detail" button here
                          _showBottomSheet(context);
                        },
                  style: ElevatedButton.styleFrom(
                    primary: widget.isReviewSubmitted
                        ? Colors.grey
                        : Color(0xFFEC407A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.isReviewSubmitted ? 'Selesai' : 'Ulasan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _submitReview(BuildContext context) async {
  try {
    String _currentUserUid = getCurrentUserUid();

    // Assuming you have a 'comments' collection reference
    CollectionReference commentsRef =
        FirebaseFirestore.instance.collection('riwayat_laporan');

    // Prepare the data for the new comment
    Map<String, dynamic> commentData = {
      'uid': _currentUserUid,
      'rating': _rating,
      'comment': _comment,
      'time': FieldValue.serverTimestamp(),
      'isReviewSubmitted': true,
      // You can add other fields as needed, such as user ID, report ID, etc.
    };

    // Add the comment to the 'comments' collection
    await commentsRef.add(commentData);

    // Assuming you have a 'complete_reports' collection reference
    CollectionReference completeReportsRef =
        FirebaseFirestore.instance.collection('complete_reports');

    // Update the 'complete_reports' collection with the review information
    await completeReportsRef.doc(widget.reportId).update({
      'isReviewSubmitted': true,
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(
            'Review submitted successfully!',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    // Show a success message or perform any other actions as needed
  } catch (error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
            'An error occurred while submitting the review. Please try again.',
          ),
        );
      },
    );
  }
}


  // Method to show the bottom sheet when "Ulasan" button is pressed
  void _showBottomSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ulasan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                widget.isReviewSubmitted
                    ? RatingBarIndicator(
                        rating: _rating,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemSize: 32.0,
                      )
                    : RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => Transform.scale(
                          scale: 0.8,
                          child: Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _comment = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Add your review here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  maxLines: 5,
                  readOnly: widget.isReviewSubmitted,
                ),
                SizedBox(height: 10),
                if (!widget.isReviewSubmitted)
                  ElevatedButton(
                    onPressed: () {
                      _submitReview(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFEC407A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
