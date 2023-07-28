import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_report/screens/admin_kampanye.dart';
import 'package:safe_report/screens/admin_pendampingan.dart';
import 'package:safe_report/screens/admin_rescue.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safe_report/screens/article_detail_screen.dart';
import 'package:safe_report/model/Article.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late final FirebaseAuth _auth;
  late final User? _user;
  late final String _companionId;

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    } else {
      throw ("No user logged in");
    }
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;

    if (_user != null) {
      _companionId = _user!.uid;
    } else {
      // handle this case where _user is null
    }
    fetchArticles();
  }

  void fetchArticles() async {
    final QuerySnapshot snapshot =
        await _firestore.collection('articles').get();

    setState(() {
      articles = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Article(
          title: data['title'] ?? "No title",
          description: data['description'] ?? "No description",
          imageUrl: data['image_url'] ??
              "https://images.unsplash.com/photo-1575936123452-b67c3203c357?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%3D&w=1000&q=80",
        );
      }).toList();
    });
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
            body: ListView(
              children: <Widget>[
                Padding(
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
                              backgroundImage: AssetImage(
                                  'assets/images/default_avatar.png'),
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
                              SizedBox(width: 3),
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
                                      "Admin",
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
                      SizedBox(height: 30),
                      // Bagian atas kategori
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rescue
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminRescue(), // Ganti dengan halaman kampanye yang sesuai
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                          ),
                          // Pendampingan
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminPendampingan(
                                        companionId: _companionId)),
                              );
                            },
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
                      SizedBox(height: 20),
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
                                SizedBox(height: 8),
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      KampanyeScreen(), // Ganti dengan halaman kampanye yang sesuai
                                ),
                              );
                            },
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
                                        "assets/images/kampanye_logo.png"),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Kampanye",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF9D9D9D),
                                  ),
                                ),
                              ],
                            ),
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
                                SizedBox(height: 8),
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
                      SizedBox(height: 30),
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
                                        GestureDetector(
                                          onTap: () {
                                            launch("tel://0778431777");
                                            Navigator.of(context).pop();
                                          },
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor: Colors.red,
                                                backgroundImage: AssetImage(
                                                    'assets/images/rs.png'),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Rumah Sakit',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Icon(
                                                Icons.phone,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () {
                                            launch("tel:0778371560");
                                            Navigator.of(context).pop();
                                          },
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor: Colors.red,
                                                backgroundImage: AssetImage(
                                                    'assets/images/pemadam.png'),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Pemadam Kebakaran',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Icon(
                                                Icons.phone,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () {
                                            launch("tel://112");
                                            Navigator.of(context).pop();
                                          },
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor: Colors.red,
                                                backgroundImage: AssetImage(
                                                    'assets/images/polisi.png'),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Kantor Polisi',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Icon(
                                                Icons.phone,
                                                color: Colors.red,
                                                size: 20,
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
                                color: Colors.red,
                                width: 2,
                              ),
                              minimumSize: Size(double.infinity, 55),
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
                      // Article
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          "Informasi dan Berita",
                          style: GoogleFonts.inter(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ArticleDetailScreen(
                                          article: articles[index]),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(top: 20.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Container(
                                            height: 150.0,
                                            width: 320.0,
                                            child: Image.network(
                                              articles[index].imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        contentPadding: EdgeInsets.only(
                                          left: 20.0,
                                          right: 20.0,
                                          bottom: 20.0,
                                          top: 15.0,
                                        ),
                                        title: Text(
                                          articles[index].title.length > 150
                                              ? articles[index]
                                                      .title
                                                      .substring(0, 150) +
                                                  '...'
                                              : articles[index].title,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          articles[index].description.length >
                                                  150
                                              ? articles[index]
                                                      .description
                                                      .substring(0, 150) +
                                                  '...'
                                              : articles[index].description,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
