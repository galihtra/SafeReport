import 'package:flutter/material.dart';


class Status extends StatelessWidget {
  const Status({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Status",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16  
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }
}