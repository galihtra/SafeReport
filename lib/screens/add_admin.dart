import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/screens/profile_screen.dart';

class AddAdmin extends StatefulWidget {
  @override
  _AddAdminState createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  String _selectedGender = 'Pria'; // Default gender value
  String _selectProdi = 'Teknik Informatika';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  String _errorMessage = '';

  void _addAdmin() async {
    setState(() {
      _errorMessage = '';
    });

    try {
      // Create a new user with the entered email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Add the admin role and other details to the user document
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'isAdmin': true,
        'email': _emailController.text,
        'name': _fullNameController.text,
        'gender': _selectedGender,
        'prodi': _selectProdi,
        'no_telp':_noTelpController.text,
      });

      _showNotification('Relawan berhasil ditambahkan');
      Navigator.pop(context);
      // Close the AddAdmin screen after adding admin
    } catch (error) {
      print('Error adding admin: $error');
      setState(() {
        _errorMessage = 'Failed to add admin. Please try again later.';
      });
    }
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Admin'),
        backgroundColor: Color(0xFFEC407A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _noTelpController,
                decoration: InputDecoration(
                  labelText: 'No HandPhone',
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: <String>['Pria', 'Wanita']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          value == 'Pria' ? Icons.male : Icons.female,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Gender',
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectProdi,
                items: <String>['Teknik Informatika', 'Teknik Elektro', 'Geomatika', 'Akuntansi Manajemen', 'Rekayasa Keamanan Siber', 'Rekayasa Perangkat Lunak', 'Multimedia & Jaringan', 'Manajemen Bisnis', 'Teknik Mesin']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                        value,
                      ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectProdi = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Gender',
                ),
              ),
              SizedBox(height: 16.0),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addAdmin,
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
