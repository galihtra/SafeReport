import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_report/model/edukasi_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AdminEdukasi extends StatefulWidget {
  @override
  _AdminEdukasi createState() => _AdminEdukasi();
}

class _AdminEdukasi extends State<AdminEdukasi> {
  TextEditingController _addItemController = TextEditingController();
  late CollectionReference linkRef;
  List<String> videoID = [];
  bool showItem = false;
  final youtubeUrlRegex =
      RegExp(r"^(https?\:\/\/)?((www\.)?youtube\.com|youtu\.?be)\/.+");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video Edukasi'),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              key: Key('inputFieldKey'),
              controller: _addItemController,
              onSubmitted: (_) => _validateAndAddItem(),
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'URL Video Anda',
                suffixIcon: GestureDetector(
                  child: Icon(Icons.add, size: 32),
                  onTap: _validateAndAddItem,
                ),
              ),
            ),
          ),
          showItem
              ? Expanded(
                  child: ListView.builder(
                    key: Key('listViewBuilderKey'),
                    itemCount: videoID.length,
                    itemBuilder: (context, index) {
                      final videoId = videoID[index];
                      return Container(
                        margin: EdgeInsets.all(8),
                        child: YoutubePlayer(
                          controller: YoutubePlayerController(
                            initialVideoId: videoId,
                            flags: YoutubePlayerFlags(
                              autoPlay: false,
                            ),
                          ),
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.blue,
                          progressColors: ProgressBarColors(
                            playedColor: Colors.blue,
                            handleColor: Colors.blueAccent,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void initState() {
    linkRef = FirebaseFirestore.instance.collection('links');
    super.initState();
    getData();
  }

  _validateAndAddItem() {
    if (youtubeUrlRegex.hasMatch(_addItemController.text)) {
      _addItemFunction();
    } else {
      FocusScope.of(context).unfocus();
      _addItemController.clear();
      _showSnackBar('Harap masukkan tautan yang valid', Colors.red);
    }
  }

  _addItemFunction() async {
    try {
      String videoUrl = _addItemController.text;
      final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? '';
      if (videoID.contains(videoId)) {
        _showSnackBar('Tautan sudah ada dalam daftar.', Colors.red);
        return;
      }

      await linkRef.add(
        {'videoUrl': videoUrl},
      );
      setState(() {
        videoID.add(videoId);
      });
      _showSnackBar('Memperbarui...', Colors.green);
      FocusScope.of(context).unfocus();
      _addItemController.clear();
    } catch (e) {
      _showSnackBar('Gagal menambahkan tautan.', Colors.red);
    }
  }

  getData() async {
    try {
      final snapshot = await linkRef.get();
      List<String> newData = snapshot.docs.map((doc) {
        final videoUrl = doc.get('videoUrl') as String;
        final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? '';
        return videoId;
      }).toList();
      setState(() {
        videoID = newData;
        showItem = true;
      });
    } catch (e, s) {
      print('Error: $e');
      print('Stack trace: $s');
      _showSnackBar('Gagal mengambil data.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
