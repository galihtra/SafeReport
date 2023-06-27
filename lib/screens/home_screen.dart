import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    } else {
      throw ("No user logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getUserData(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (data['image_url'] != null)
                        CircleAvatar(
                          backgroundImage: NetworkImage(data['image_url']),
                          radius: 22,
                        )
                      else
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage:
                              AssetImage('assets/images/default_avatar.png'),
                          radius: 22,
                        ),
                      Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.waving_hand,
                            color: Color(0xFFEC407A),
                            size: 28,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Hi, ",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  data['name'],
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  // Bagian atas kategori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rescue
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 75,
                                height: 75,
                                color: Colors.red,
                                child: Image.asset(
                                    "assets/images/rescue_logo.png"),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Rescue",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9D9D9D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Pendampingan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 75,
                              height: 75,
                              color: Color(0xFFF4E8EA),
                              child: Image.asset(
                                  "assets/images/pendampingan_logo.png"),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Pendampingan",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF9D9D9D),
                            ),
                          ),
                        ],
                      ),
                      // Konsultasi Online
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 75,
                                height: 75,
                                color: Color(0xFFF4E8EA),
                                child: Image.asset(
                                    "assets/images/konsultasi_logo.png"),
                              ),
                            ),
                            SizedBox(height: 8),
                            Column(
                              children: [
                                Text(
                                  "Konsultasi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF9D9D9D),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Online",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF9D9D9D),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Bagian bawah kategori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Edukasi
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 75,
                                height: 75,
                                color: Color(0xFFF4E8EA),
                                child: Image.asset(
                                    "assets/images/edukasi_logo.png"),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Edukasi",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9D9D9D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Kampanye
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 75,
                              height: 75,
                              color: Color(0xFFF4E8EA),
                              child: Image.asset(
                                  "assets/images/kampanye_logo.png"),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Kampanye",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF9D9D9D),
                            ),
                          ),
                        ],
                      ),
                      // Pelaporan
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 75,
                                height: 75,
                                color: Color(0xFFF4E8EA),
                                child: Image.asset(
                                    "assets/images/pelaporan_logo.png"),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Pelaporan",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9D9D9D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  // Kontak Darurat
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('KONTAK DARURAT'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
// Rumah Sakit
                                    GestureDetector(
                                      onTap: () {
                                        launch(
                                            "tel://12345678"); // Ganti nomor telepon dengan nomor rumah sakit
                                        Navigator.of(context).pop();
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Rumah Sakit',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
// Pemadam Kebakaran
                                    GestureDetector(
                                      onTap: () {
                                        launch(
                                            "tel://12345678"); // Ganti nomor telepon dengan nomor pemadam kebakaran
                                        Navigator.of(context).pop();
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Pemadam Kebakaran',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
// Kantor Polisi
                                    GestureDetector(
                                      onTap: () {
                                        launch(
                                            "tel://12345678"); // Ganti nomor telepon dengan nomor kantor polisi
                                        Navigator.of(context).pop();
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Kantor Polisi',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: Colors.red, // Warna border merah
                            width: 2,
                          ),
                          minimumSize: Size(double.infinity,
                              55), // Lebar menyesuaikan ukuran perangkat
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.red,
                              size: 28,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'KONTAK DARURAT',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
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
          );
        } else if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            body: Center(child: Text("No user logged in")),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 5,
              ),
            ),
          );
        }
      },
    );
  }
}
