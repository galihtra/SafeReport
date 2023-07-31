import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edukasi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EdukasiNotif(),
    );
  }
}

class EdukasiNotif extends StatefulWidget {
  const EdukasiNotif({Key? key}) : super(key: key);

  @override
  State<EdukasiNotif> createState() => _EdukasiNotifState();
}

class _EdukasiNotifState extends State<EdukasiNotif> {
  final YoutubeExplode _youtubeExplode = YoutubeExplode();

  @override
  void dispose() {
    _youtubeExplode.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pembelajaran Saya",
          style: GoogleFonts.roboto(color: Colors.black), // Use Roboto font.
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ), // Add margins here.
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('links').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // If there's no data, you can display a message or an empty widget.
            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No videos found.'),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final videoUrl = snapshot.data!.docs[index].get('videoUrl');
                return FutureBuilder<Video>(
                  future: _youtubeExplode.videos.get(videoUrl),
                  builder: (context, AsyncSnapshot<Video> videoSnapshot) {
                    if (videoSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return SizedBox.shrink();
                    }

                    if (videoSnapshot.hasError) {
                      return Text('Error: ${videoSnapshot.error}');
                    }

                    final video = videoSnapshot.data;
                    if (video == null) {
                      return SizedBox.shrink();
                    }

                    return EdukasiCard(video: video);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class EdukasiCard extends StatefulWidget {
  final Video video;

  const EdukasiCard({required this.video, Key? key}) : super(key: key);

  @override
  State<EdukasiCard> createState() => _EdukasiCardState();
}

class _EdukasiCardState extends State<EdukasiCard> {
  String _progressText = '';

  @override
  void initState() {
    super.initState();
    _updateProgressText(Duration.zero); // Set initial progress text
  }

  void _updateProgressText(Duration currentTime) {
    final totalTime = widget.video.duration;
    if (totalTime != null) {
      final totalSeconds = totalTime.inSeconds.toDouble();
      final currentSeconds = currentTime.inSeconds.toDouble();
      final percentage = totalSeconds > 0 ? (currentSeconds / totalSeconds) * 100 : 0;
      final minutesLeft = (totalSeconds - currentSeconds) ~/ 60;
      _progressText = '${percentage.toStringAsFixed(0)}% - ${minutesLeft} minutes left';
    } else {
      _progressText = 'Video duration not available';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  widget.video.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  _progressText,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
