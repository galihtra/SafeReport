import 'package:flutter/material.dart';

class StoryPelaporanUser extends StatefulWidget {

  @override
  _StoryPelaporanUser createState() => _StoryPelaporanUser();
}


class _StoryPelaporanUser extends State<StoryPelaporanUser> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }
}