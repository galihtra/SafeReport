import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:safe_report/screens/signin_screen.dart';
import 'package:safe_report/screens/add_admin.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _imageURL;

  bool _isAdmin = false; // Variable to store admin status

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();
      if (data != null) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          try {
            _imageURL = data['image_url'];
          } catch (e) {
            print('Caught error: $e');
          }
          _isAdmin = data['isAdmin'] ?? false;
        });
      }
    }
  }

  Future<void> _updateProfileData() async {
    await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': _nameController.text,
      'email':
          _emailController.text, // Path to the selected image or empty string
    });

    if (_selectedImage != null) {
      _imageURL = await uploadImageToStorage(_selectedImage!);

      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'image_url': _imageURL});
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateEmail(_emailController.text);
    }

    _showNotification('Profile updated successfully');
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    String fileName = imageFile.path.split('/').last;
    final Reference storageRef =
        FirebaseStorage.instance.ref().child('profile_images/$fileName');
    final UploadTask uploadTask = storageRef.putFile(imageFile);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    final String downloadURL = await taskSnapshot.ref.getDownloadURL();
    return downloadURL;

    // Kembalikan URL default jika tidak ada proses pengunggahan
  }

  Future<void> _updateProfileImage() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }

    _imageURL = await uploadImageToStorage(_selectedImage!);
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
          title: Text('Profil'),
          backgroundColor:
              Color(0xFFEC407A), // Set the app bar color to transparent
          elevation: 0, // Remove the shadow
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFFEC407A),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              if (_isAdmin) // Check if the current user is an admin
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Tambah Relawan'),
                  onTap: () {
                    // Perform the desired action when the Add Admin option is tapped
                    // For example, navigate to the AddAdminScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddAdmin()),
                    );
                  },
                ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(children: [
            Image(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.2,
              fit: BoxFit.cover,
              image: AssetImage(
                  'assets/images/profile_bg.png'), // Replace with the path to your image
            ),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 90),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: _updateProfileImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 60,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_imageURL != null && _imageURL!.isNotEmpty)
                                  ? NetworkImage(_imageURL!)
                                  : AssetImage(
                                          'assets/images/default_avatar.png')
                                      as ImageProvider<Object>,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: _updateProfileImage,
                            icon: Image.asset(
                              'assets/images/camera.png', // Replace with the path to your image
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Nama',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.grey)),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        fillColor: Colors.grey // Remove underline
                        ),
                  ),
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Email',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.grey,
                      )),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: InputBorder.none, // Remove underline
                    ),
                  ),
                ),
                const SizedBox(height: 45),
                ElevatedButton(
                  onPressed: _updateProfileData,
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFFEC407A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size(350, 55),
                  ),
                  child: Text(
                    'Perbarui Profil',
                    style: GoogleFonts.inter(fontSize: 18),
                  ),
                ),
              ],
            ),
          ]),
        ));
  }
}
