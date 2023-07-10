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

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: (data['image_url'] != null)
                    ? CircleAvatar(
                        radius:
                            25, // Setengah dari ukuran yang Anda inginkan (50/2)
                        backgroundImage: NetworkImage(data['image_url']),
                      )
                    : CircleAvatar(
                        radius:
                            25, // Setengah dari ukuran yang Anda inginkan (50/2)
                        child: Icon(Icons.person),
                      ),
                title: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text(
                    data['name'] ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text(
                    data['gender'] ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
