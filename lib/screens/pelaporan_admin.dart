import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:auto_reload/auto_reload.dart';
import 'dart:async';

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

  ReportDetailPage({required this.formData, required this.reportRef});

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  final GlobalKey<_ReportDetailPageState> _reportDetailPageKey = GlobalKey<_ReportDetailPageState>();
  bool _verificationStatus = false;

  Future<void> _checkVerificationStatus() async {
    var reportSnapshot = await widget.reportRef.get();
    if (reportSnapshot.exists) {
      var reportData = reportSnapshot.data() as Map<String, dynamic>;
      var verificationStatus = reportData['verification'];
      if (verificationStatus is bool) {
        setState(() {
          _verificationStatus = verificationStatus;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    // Call your refresh logic here, in this case, fetching data from API
    // Use the GlobalKey to access the state of the ReportDetailPage and trigger the refresh
    await _reportDetailPageKey.currentState?._handleRefresh();
    await Future.delayed(Duration(seconds: 2));
    await _checkVerificationStatus();
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
          "tanggal_diterima": DateFormat('dd MMMM yyyy').format(currentDate),
          "jam_diterima": TimeOfDay.fromDateTime(currentDate).format(context),
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Report Accepted"),
              content: Text("The report has been accepted successfully"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                )
              ],
            );
          },
        );
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
          "tanggal_diterima": DateFormat('dd MMMM yyyy').format(currentDate),
          "jam_diterima": TimeOfDay.fromDateTime(currentDate).format(context),
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Report Rejected"),
              content: Text("The report has been rejected"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                )
              ],
            );
          },
        );
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

  Future<void> _deleteReport(BuildContext context) async {
    try {
      await widget.reportRef.delete();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Report Deleted"),
            content: Text("The report has been deleted successfully"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              )
            ],
          );
        },
      );
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

  String _truncateText(String text, int maxLength) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength) + '...';
    }
    return text;
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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DataTable(
                  columns: [
                    DataColumn(label: Text('Data')),
                    DataColumn(label: Text('Keterangan')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Nama')),
                      DataCell(Text('${widget.formData['nama'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('NIM')),
                      DataCell(Text('${widget.formData['nim'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('No. Telepon')),
                      DataCell(Text('${widget.formData['noTelp'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Nama Pelaku')),
                      DataCell(
                          Text('${widget.formData['namaPelaku'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('No. Telepon Pelaku')),
                      DataCell(Text(
                          '${widget.formData['noTelpPelaku'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Deskripsi Pelaku')),
                      DataCell(Text(
                          '${widget.formData['deskripsiPelaku'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Tanggal Kejadian')),
                      DataCell(Text(
                          '${widget.formData['tanggalKejadian'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Jam')),
                      DataCell(Text('${widget.formData['jam'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Tempat Kejadian')),
                      DataCell(Text(
                          '${widget.formData['tempatKejadian'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Kronologi Kejadian')),
                      DataCell(Text(
                        '${_truncateText(widget.formData['kronologiKejadian'] ?? 'No Data', 12)}',
                        overflow: TextOverflow.ellipsis,
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Nama Saksi')),
                      DataCell(
                          Text('${widget.formData['namaSaksi'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('No. Telepon Saksi')),
                      DataCell(
                          Text('${widget.formData['noTelpSaksi'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Keterangan Saksi')),
                      DataCell(Text(
                          '${widget.formData['keteranganSaksi'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Gender')),
                      DataCell(Text('${widget.formData['gender'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Jurusan')),
                      DataCell(
                          Text('${widget.formData['jurusan'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Program Studi')),
                      DataCell(Text('${widget.formData['prodi'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Kelas')),
                      DataCell(Text('${widget.formData['kelas'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Jenis Kasus')),
                      DataCell(
                          Text('${widget.formData['jenisKasus'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Bentuk Kasus')),
                      DataCell(
                          Text('${widget.formData['bentukKasus'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Gender Pelaku')),
                      DataCell(Text(
                          '${widget.formData['genderPelaku'] ?? 'No Data'}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Jurusan Pelaku')),
                      DataCell(Text('${widget.formData['jurusanPelaku'] ?? ''}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Program Studi Pelaku')),
                      DataCell(Text('${widget.formData['prodiPelaku'] ?? ''}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Kelas Pelaku')),
                      DataCell(Text('${widget.formData['kelasPelaku'] ?? ''}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Diterima Oleh')),
                      DataCell(Text(
                        '${_truncateText(widget.formData['diterima_oleh'] ?? 'No Data', 12)}',
                        overflow: TextOverflow.ellipsis,
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Tanggal Diterima')),
                      DataCell(
                          Text('${widget.formData['tanggal_diterima'] ?? ''}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Jam Diterima')),
                      DataCell(Text('${widget.formData['jam_diterima'] ?? ''}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Verifikasi')),
                      DataCell(Text('${widget.formData['verification'] ?? ''}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Tanggal Verifikasi')),
                      DataCell(Text(
                          '${widget.formData['tanggal_diverifikasi'] ?? ''}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Jam Verifikasi')),
                      DataCell(
                          Text('${widget.formData['jam_diverifikasi'] ?? ''}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Bukti Pendukung')),
                      DataCell(
                        Image.network(
                          widget.formData['bukti_pendukung'] ?? 'No Data',
                          width: 100, // Adjust the width and height as needed
                          height: 100,
                          fit: BoxFit.fitWidth,
                          // Adjust the fit property based on how you want the image to be displayed
                        ),
                      ),
                    ]),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_verificationStatus == false &&
                        widget.formData['verification'] == null)
                      ElevatedButton(
                        onPressed: () async {
                          await _terimaReport(context, widget.reportRef);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFEC407A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text('Terima Report'),
                      ),
                    if (_verificationStatus == false &&
                        widget.formData['verification'] == null)
                      SizedBox(width: 10),
                    if (_verificationStatus == false &&
                        widget.formData['verification'] == null)
                      ElevatedButton(
                        onPressed: () async {
                          await _tolakReport(context, widget.reportRef);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFEC407A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text('Tolak Report'),
                      ),
                    if (
                        widget.formData['verification'] != null)
                      if (widget.formData['verification'] == true ||
                          widget.formData['verification'] == false && widget.formData['selesai'] == 'selesai')
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
                    if (
                        widget.formData['verification'] == true &&
                        widget.formData['selesai'] != 'selesai')
                      SizedBox(width: 10),
                    if (
                        widget.formData['verification'] == true &&
                        widget.formData['selesai'] != 'selesai')
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

  void _selesai(BuildContext context) async {
    // Get the data from the 'report' collection
    DocumentSnapshot reportSnapshot = await widget.reportRef.get();
    Map<String, dynamic> reportData =
        reportSnapshot.data() as Map<String, dynamic>;

    // Check if 'diterima_oleh' is null
    if (reportData['diterima_oleh'] == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'The report must be "Diterima Oleh" before marking it as done.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              )
            ],
          );
        },
      );
    } else {
      // Add the 'selesai' field with value 'selesai' in the 'report' collection
      try {
        await widget.reportRef.update({
          'selesai': 'selesai',
        });

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

    // Add data to the 'complete_reports' collection
    try {
      await FirebaseFirestore.instance.collection('complete_reports').add({
        'uid': reportData['uid'],
        'nama': reportData['nama'],
        'nim': reportData['nim'],
        'bukti_pendukung': reportData['bukti_pendukung'],
        'jam': reportData['jam'],
        'tanggal_kejadian': reportData['tanggalKejadian'],
        'prodi': reportData['prodi'],
        'gender': reportData['gender'],
        'bentuk_kasus': reportData['bentukKasus'],
        'jenis_kasus': reportData['jenisKasus'],
        'selesai': 'selesai',
        'isReviewSubmitted': false,
      });
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
              'An error occurred while adding data to complete_reports collection. Please try again.',
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
              alignment:
                  Alignment.centerRight, // Align the buttons to the right
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Make the row take minimum space
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
                      _selesai(
                          context); // Replace _submitOtherData with your function for the second button
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(
                          0xFFEC407A), // Change the color of the second button
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
