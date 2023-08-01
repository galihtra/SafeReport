import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryAdmin extends StatefulWidget {
  const HistoryAdmin({Key? key}) : super(key: key);

  @override
  State<HistoryAdmin> createState() => _HistoryAdmin();
}

class _HistoryAdmin extends State<HistoryAdmin> {
  // Function to show the detail dialog
  void _showDetailDialog(String tanggal, String jam, String nama,
      String jurusan, String prodi, String no_telp, String bentuk_kasus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama: $nama'),
              Text('Jurusan: $jurusan'),
              Text('Prodi: $prodi'),
              Text('No. Telp: $no_telp'),
              Text('Bentuk Kasus: $bentuk_kasus'),
              Text('Tanggal: $tanggal'),
              Text('Jam: $jam')
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                child: Text(
                  "OK",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History User",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('report_history').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                String nama = document['nama'];
                String jurusan = document['jurusan'];
                String prodi = document['prodi'];
                String noTelp = document['no_telp'];
                String bentukKasus = document['bentuk_kasus'];
                bool verification = document['verification'];

                String statusText = verification ? 'diterima' : 'ditolak';
                Color statusColor = verification ? Colors.green : Colors.red;

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: InkWell(
                    onTap: () {
                      String tanggalInfo;
                      String jamInfo;
                      if (verification) {
                        tanggalInfo = document['tanggal_diterima'];
                        jamInfo = document['jam_diterima'];
                      } else {
                        tanggalInfo = document['tanggal_ditolak'];
                        jamInfo = document['jam_ditolak'];
                      }
                      _showDetailDialog(tanggalInfo, jamInfo, nama, jurusan,
                          prodi, noTelp, bentukKasus);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Stack(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            title: Text(
                              '$nama',
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$jurusan - $prodi'),
                                Text('No. Telp: $noTelp'),
                                Text('Bentuk Kasus: $bentukKasus'),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: statusColor,
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
