import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
      await reportRef.update({'status': 'Accepted'});
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
            Text(
              'NIM: ${widget.formData['nim'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'No. Telepon: ${widget.formData['noTelp'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Nama Pelaku: ${widget.formData['namaPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'No. Telepon Pelaku: ${widget.formData['noTelpPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Deskripsi Pelaku: ${widget.formData['deskripsiPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Tanggal Kejadian: ${widget.formData['tanggalKejadian'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Tempat Kejadian: ${widget.formData['tempatKejadian'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Kronologi Kejadian: ${widget.formData['kronologiKejadian'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Nama Saksi: ${widget.formData['namaSaksi'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'No. Telepon Saksi: ${widget.formData['noTelpSaksi'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Keterangan Saksi: ${widget.formData['keteranganSaksi'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Gender: ${widget.formData['gender'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Jurusan: ${widget.formData['jurusan'] ?? ''}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Program Studi: ${widget.formData['prodi'] ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Kelas: ${widget.formData['kelas'] ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Jenis Kasus: ${widget.formData['jenisKasus'] ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Bentuk Kasus: ${widget.formData['bentukKasus'] ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Gender Pelaku: ${widget.formData['genderPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Jurusan Pelaku: ${widget.formData['jurusanPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Program Studi Pelaku: ${widget.formData['prodiPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Kelas Pelaku: ${widget.formData['kelasPelaku'] ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
