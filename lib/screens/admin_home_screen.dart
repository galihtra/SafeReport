import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Text(
              'Welcome Admin',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    String? name = data['name']; // The ? means name can be null
                    String? email = data['email'];

                    return ListTile(
                      title: Text(name ??
                          'No Name'), // If name is null, display 'No Name'
                      subtitle: Text(email ??
                          'No Email'), // If email is null, display 'No Email'
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
