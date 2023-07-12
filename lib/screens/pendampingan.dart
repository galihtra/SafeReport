import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Pendampingan extends StatefulWidget {
  const Pendampingan({Key? key}) : super(key: key);

  @override
  _PendampinganState createState() => _PendampinganState();
}

class _PendampinganState extends State<Pendampingan> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pendamping",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('isAdmin', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return InkWell(
                  onTap: () {
                    // Navigasi ke halaman detail item
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPendamping(data: data),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: (data['image_url'] != null)
                        ? CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(data['image_url']),
                          )
                        : CircleAvatar(
                            radius: 25,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            backgroundColor: Color(0xFFEC407A),
                          ),
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 1),
                      child: Text(
                        data['name'] ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text(
                            data['gender'] ?? '',
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            '(${data['prodi'] ?? ''})',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF98A2B3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class DetailPendamping extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailPendamping({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(''),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 300.0,
              width: MediaQuery.of(context)
                  .size
                  .width, // Lebar sesuai ukuran layar
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: (data['image_url'] != null)
                      ? NetworkImage(data['image_url'])
                      : AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              data['name'] ?? '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              data['gender'] ?? '',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '(${data['prodi'] ?? ''})',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF98A2B3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
