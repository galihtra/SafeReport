import 'package:flutter/material.dart';
import 'package:safe_report/model/Article.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  ArticleDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Memastikan body berada dibelakang AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Menghilangkan shadow
        title: Text(''), // Menghilangkan teks
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share('${article.title}\n\n${article.description}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 330.0,
              width: MediaQuery.of(context)
                  .size
                  .width, // Lebar sesuai ukuran layar
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(article.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Text(
                    article.title,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEC407A),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    article.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF8C8A8A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
