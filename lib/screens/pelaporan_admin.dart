import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PelaporanAdmin extends StatefulWidget {
  @override
  _PelaporanAdminState createState() => _PelaporanAdminState();
}

class _PelaporanAdminState extends State<PelaporanAdmin> {
  List<DocumentSnapshot> documents = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Add GestureDetector to handle tap events
      onTap: () {
        // Hide keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "DATA",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('report').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            documents = snapshot.data!.docs;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    documents[index].data() as Map<String, dynamic>;

                // Check if UID in "report" collection matches UID in "users" collection
                String? uid = data['uid'] as String?;
                // Assuming 'uid' field exists in the 'report' collection
                if (uid == null || uid.isEmpty) {
                  return ListTile(
                    title: Text('Invalid user ID'),
                  );
                }

                Stream<DocumentSnapshot> userStream = FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots();

                return StreamBuilder<DocumentSnapshot>(
                  stream: userStream,
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return ListTile(
                        title: Text('Loading...'),
                      );
                    }

                    Map<String, dynamic> userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;

                    // Retrieve image_url, name, and gender from the "users" collection
                    String imageUrl = userData['image_url'] ?? '';
                    // Assuming 'image_url' field exists in the 'users' collection
                    String name = userData['name'] ?? '';
                    // Assuming 'name' field exists in the 'users' collection
                    String gender = userData['gender'] ?? '';
                    // Assuming 'gender' field exists in the 'users' collection

                    return GestureDetector(
                      // Add GestureDetector to handle tap events
                      // Add GestureDetector to handle tap events
                      onTap: () {
                        if (data['status'] == 'Accepted') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportDetailPage(
                                formData: data,
                                reportRef: documents[index].reference,
                              ),
                            ),
                          );
                        } else {
                          // Handle case where status is not accepted
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Invalid Action'),
                                content: Text(
                                    'You can only view reports with "Accepted" status.'),
                              );
                            },
                          );
                        }
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : AssetImage('assets/images/default_avatar.png')
                                  as ImageProvider<Object>?,
                          backgroundColor: Color(0xFFF2F2F2),
                        ),
                        title: Padding(
                          padding: EdgeInsets.only(bottom: 3),
                          child: Text(
                            name,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(bottom: 3),
                          child: Text(
                            gender,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        trailing: data['status'] == null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _acceptReport(
                                          context, documents[index].reference);
                                    },
                                    icon: Icon(Icons.check),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _rejectReport(
                                          context, documents[index].reference);
                                    },
                                    icon: Icon(Icons.close),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _acceptReport(
      BuildContext context, DocumentReference reportRef) async {
    try {
      DateTime currentDate = DateTime.now();

      FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;
      if (currentUser != null) {
        String adminUID = currentUser.uid;

        await reportRef.update({
          'status': 'Accepted',
          'tanggal_diterima_petugas': Timestamp.fromDate(currentDate),
          'adminUID': adminUID,
        });

        setState(() {
          // Rebuild the UI to reflect the updated report status
        });
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while accepting the report. Please try again.'),
          );
        },
      );
    }
  }

  Future<void> _rejectReport(
      BuildContext context, DocumentReference reportRef) async {
    try {
      await reportRef.update({'status': 'Rejected'});
      setState(() {
        // Rebuild the UI to reflect the updated report status
      });
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while rejecting the report. Please try again.'),
          );
        },
      );
    }
  }
}

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final DocumentReference reportRef;

  ReportDetailPage({
    required this.formData,
    required this.reportRef,
  });

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  Future<void> _deleteReport(BuildContext context) async {
    try {
      await widget.reportRef.delete();
      Navigator.pop(context);
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while deleting the report. Please try again.'),
          );
        },
      );
    }
  }

  Future<void> _terimaReport(
      BuildContext context, DocumentReference reportRef) async {
    try {
      DateTime currentDate = DateTime.now();

      FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;
      if (currentUser != null) {
        String adminUID = currentUser.uid;

        await reportRef.update({
          "verification": true,
        });

        setState(() {
          // Rebuild the UI to reflect the updated report status
        });
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while accepting the report. Please try again.'),
          );
        },
      );
    }
  }

  Future<void> _tolakReport(
      BuildContext context, DocumentReference reportRef) async {
    try {
      DateTime currentDate = DateTime.now();

      FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;
      if (currentUser != null) {
        String adminUID = currentUser.uid;

        await reportRef.update({
          "verification": false,
        });

        setState(() {
          // Rebuild the UI to reflect the updated report status
        });
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while accepting the report. Please try again.'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "REPORT DETAIL",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama: ${widget.formData['nama'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'NIM: ${widget.formData['nim'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'No. Telepon: ${widget.formData['noTelp'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Nama Pelaku: ${widget.formData['namaPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'No. Telepon Pelaku: ${widget.formData['noTelpPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Deskripsi Pelaku: ${widget.formData['deskripsiPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Tanggal Kejadian: ${widget.formData['tanggalKejadian'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Tempat Kejadian: ${widget.formData['tempatKejadian'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Kronologi Kejadian: ${widget.formData['kronologiKejadian'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Nama Saksi: ${widget.formData['namaSaksi'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'No. Telepon Saksi: ${widget.formData['noTelpSaksi'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Keterangan Saksi: ${widget.formData['keteranganSaksi'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Gender: ${widget.formData['gender'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Jurusan: ${widget.formData['jurusan'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Program Studi: ${widget.formData['prodi'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Kelas: ${widget.formData['kelas'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Jenis Kasus: ${widget.formData['jenisKasus'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Bentuk Kasus: ${widget.formData['bentukKasus'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Gender Pelaku: ${widget.formData['genderPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Jurusan Pelaku: ${widget.formData['jurusanPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Program Studi Pelaku: ${widget.formData['prodiPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Kelas Pelaku: ${widget.formData['kelasPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Diterima Oleh: ${widget.formData['diterima_oleh'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Tanggal Diterima: ${widget.formData['tanggal_diterima'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Jam Diterima: ${widget.formData['jam_diterima'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'Verifikasi: ${widget.formData['verification'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            SizedBox(
              height: 4,
            ),
            Text("Bukti Pendukung:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                )),
            SizedBox(
              height: 4,
            ),
            Image.network(
              widget.formData['bukti_pendukung'] ?? '',
              width: 200, // Adjust the width and height as needed
              height: 200,
              fit: BoxFit
                  .cover, // Adjust the fit property based on how you want the image to be displayed
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.formData['verification'] == null)
                  ElevatedButton(
                    onPressed: () {
                      _terimaReport(context, widget.reportRef);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFEC407A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('Terima Report'),
                  ),
                if (widget.formData['verification'] == null)
                  SizedBox(width: 10),
                if (widget.formData['verification'] == null)
                  ElevatedButton(
                    onPressed: () {
                      _tolakReport(context, widget.reportRef);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFEC407A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('Tolak Report'),
                  ),
                if (widget.formData['verification'] != null &&
                    widget.formData['verification'] == true || widget.formData['verification'] == false)
                  ElevatedButton(
                    onPressed: () {
                      _deleteReport(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFEC407A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('Delete Report'),
                  ),
                if (widget.formData['verification'] != null &&
                    widget.formData['verification'] == true ||
                    widget.formData['verification'] == false)
                  SizedBox(width: 10),
                if (widget.formData['verification'] != null &&
                    widget.formData['verification'] == true || widget.formData['verification'] == false)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiterimaOlehPage(
                            reportRef: widget.reportRef,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFEC407A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('Diterima Oleh'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DiterimaOlehPage extends StatefulWidget {
  final DocumentReference reportRef;

  DiterimaOlehPage({
    required this.reportRef,
  });

  @override
  _DiterimaOlehPageState createState() => _DiterimaOlehPageState();
}

class _DiterimaOlehPageState extends State<DiterimaOlehPage> {
  String? diterimaOleh;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void _submitData() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedTime = selectedTime.format(context);

    // Update the report's information with the admin's name and note
    try {
      await widget.reportRef.update({
        'tanggal_diterima': formattedDate,
        'jam_diterima': formattedTime,
        'diterima_oleh': diterimaOleh,
      });

      // Navigate back to the previous page (ReportDetailPage)
      Navigator.pop(context);
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
              'An error occurred while updating the report. Please try again.',
            ),
          );
        },
      );
    }
  }

  void _selesai() async {
    // Update the report's information with the admin's name and note
    try {
      await widget.reportRef.update({
       'selesai': 'selesai'
      });
      // Navigate back to the previous page (ReportDetailPage)
      Navigator.pop(context);
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
              'try again.',
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Diterima Oleh",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextFormField(
              initialValue: diterimaOleh,
              onChanged: (newValue) {
                setState(() {
                  diterimaOleh = newValue;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(
                  color: Color(0xFFCECCCC),
                ),
                hintText: 'Diterima Oleh', // Set your hint text here
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _selectDate(); // Call _selectDate function when tapped
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                    // Use the selected date to display in the form field
                    text: DateFormat('dd/MM/yyyy').format(selectedDate),
                  ),
                  readOnly: true, // Make the input field read-only
                  decoration: InputDecoration(
                    hintText: 'dd/mm/yyyy',
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFFCECCCC),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _selectTime(); // Call _selectTime function when tapped
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                    // Use the selected time to display in the form field
                    text: selectedTime.format(context),
                  ),
                  readOnly: true, // Make the input field read-only
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.access_time,
                      color: Color(0xFFCECCCC),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight, // Align the buttons to the right
              child: Row(
                mainAxisSize: MainAxisSize.min, // Make the row take minimum space
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _submitData();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFEC407A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('Submit'),
                  ),
                  SizedBox(width: 10), // Add some spacing between the buttons
                  ElevatedButton(
                    onPressed: () {
                      _selesai(); // Replace _submitOtherData with your function for the second button
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFEC407A), // Change the color of the second button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('Selesai'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
