import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class Edukasi extends StatefulWidget {
  const Edukasi({Key? key}) : super(key: key);

  @override
  State<Edukasi> createState() => _EdukasiState();
}

class _EdukasiState extends State<Edukasi> {
  final YoutubeExplode _youtubeExplode = YoutubeExplode();

  @override
  void dispose() {
    _youtubeExplode.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 2; // Two items per row.
    final crossAxisCount = screenWidth ~/ itemWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edukasi",
          style: GoogleFonts.roboto(color: Colors.black), // Use Roboto font.
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16), // Add margins here.
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

            // Otherwise, display the list of YouTube videos with titles, views, and upload date.
            return Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12.0, // Horizontal spacing between items.
                  mainAxisSpacing: 12.0, // Vertical spacing between items.
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final videoUrl = snapshot.data!.docs[index].get('videoUrl');
                  return FutureBuilder<Video?>(
                    future: _youtubeExplode.videos
                        .get(YoutubePlayer.convertUrlToId(videoUrl)!),
                    builder: (context, AsyncSnapshot<Video?> videoSnapshot) {
                      if (videoSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (videoSnapshot.hasError || videoSnapshot.data == null) {
                        return SizedBox
                            .shrink(); // Placeholder for videos that couldn't be fetched or had errors.
                      }

                      final video = videoSnapshot.data!;
                      final viewsCount = video.engagement?.viewCount ?? 0;
                      final formattedViewsCount = formatViewsCount(viewsCount);
                      final uploadDate = video.uploadDate ?? DateTime(2000, 1, 1); // Default date if null.

                      return GestureDetector(
                        onTap: () {
                          _playFullScreenVideo(context, video.id.value);
                        },
                        child: GridTile(
                          // Wrap the content in GridTile to remove grid lines.
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              YoutubePlayer(
                                controller: YoutubePlayerController(
                                  initialVideoId: video.id.value,
                                  flags: YoutubePlayerFlags(
                                    autoPlay: false,
                                    mute: false,
                                  ),
                                ),
                                showVideoProgressIndicator: true,
                              ),
                              SizedBox(height: 14),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.visibility, size: 10),
                                        SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            formattedViewsCount,
                                            style: GoogleFonts.roboto(
                                                fontSize: 10),
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                8), // Add some spacing between viewsCount and uploadDate
                                        Flexible(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '${DateFormat('dd MMM yyyy').format(uploadDate)}',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String formatViewsCount(int viewsCount) {
    if (viewsCount >= 1000000) {
      return '${(viewsCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewsCount >= 1000) {
      return '${(viewsCount / 1000).toStringAsFixed(1)}K';
    } else {
      return viewsCount.toString();
    }
  }

  void _playFullScreenVideo(BuildContext context, String videoId) async {
    await SystemChrome.setEnabledSystemUIOverlays(
        []); // Hide status and navigation bars
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              SystemChrome.setEnabledSystemUIOverlays(
                  SystemUiOverlay.values); // Show status and navigation bars
              await SystemChrome.setPreferredOrientations(
                  [DeviceOrientation.portraitUp]);
              return true;
            },
            child: Scaffold(
              body: YoutubePlayer(
                controller: YoutubePlayerController(
                  initialVideoId: videoId,
                  flags: YoutubePlayerFlags(autoPlay: true, mute: false),
                ),
                showVideoProgressIndicator: true,
                onEnded: (metadata) {
                  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay
                      .values); // Show status and navigation bars
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

