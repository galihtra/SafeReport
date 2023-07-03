import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class ArticleListScreen extends StatefulWidget {
  @override
  _ArticleListScreenState createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _deleteArticle(String id, String imageUrl) async {
    // Delete image from storage
    await _storage.refFromURL(imageUrl).delete();

    // Delete article from Firestore
    await _firestore.collection('articles').doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Artikel dihapus')),
    );
  }

  Future<void> _deleteArticleWithoutImage(String id) async {
    // Delete article from Firestore
    await _firestore.collection('articles').doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Artikel dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kumpulan Artikel'),
        automaticallyImplyLeading: false, // Menonaktifkan tombol kembali
        backgroundColor: Color(0xFFEC407A),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('articles').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0), // margin atas dan bawah
                child: ListTile(
                  leading: data['image_url'] != null
                      ? Container(
                          width: 80,
                          height: 180,
                          child: Image.network(data['image_url'],
                              fit: BoxFit.cover),
                        )
                      : Icon(Icons.image, size: 50),
                  title: Text(
                    data['title'].length > 100
                        ? data['title'].substring(0, 100) + '...'
                        : data['title'],
                  ),
                  subtitle: Text(
                    data['description'].length > 100
                        ? data['description'].substring(0, 100) + '...'
                        : data['description'],
                  ),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateArticleScreen(
                                id: doc.id,
                                title: data['title'],
                                description: data['description'],
                                imageUrl: data['image_url'] ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          if (data['image_url'] != null) {
                            _deleteArticle(doc.id, data['image_url']);
                          } else {
                            _deleteArticleWithoutImage(doc.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFEC407A),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddArticleScreen()),
          );
        },
      ),
    );
  }
}

class AddArticleScreen extends StatefulWidget {
  @override
  _AddArticleScreenState createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _image;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _image != null) {
      // Upload image to Firebase Storage
      TaskSnapshot snapshot = await _storage
          .ref('articles/images/${_titleController.text}')
          .putFile(_image!);

      // Get the URL of the uploaded image
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Upload article to Firestore
      await _firestore.collection('articles').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'image_url': imageUrl,
      });

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      setState(() => _image = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artikel berhasil dipublikasikan')),
      );

      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Artikel'),
        backgroundColor: Color(0xFFEC407A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Judul';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5, // Tinggi textarea berdasarkan jumlah baris
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan deskripsi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Pilih Gambar'),
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size(350, 50),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFFEC407A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size(350, 55),
                ),
                child: Text(
                  'Kirim',
                  style: GoogleFonts.inter(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateArticleScreen extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  UpdateArticleScreen({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  _UpdateArticleScreenState createState() => _UpdateArticleScreenState();
}

class _UpdateArticleScreenState extends State<UpdateArticleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _image;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.title;
    _descriptionController.text = widget.description;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Update image in Firebase Storage if a new one is selected
      String imageUrl = widget.imageUrl;
      if (_image != null) {
        // Hanya hapus gambar jika imageUrl tidak kosong
        if (widget.imageUrl.isNotEmpty) {
          await _storage.refFromURL(widget.imageUrl).delete();
        }
        TaskSnapshot snapshot = await _storage
            .ref('articles/images/${_titleController.text}')
            .putFile(_image!);
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Update article in Firestore
      await _firestore.collection('articles').doc(widget.id).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'image_url': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artikel berhasil diperbarui')),
      );

      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perbarui Artikel'),
        backgroundColor: Color(0xFFEC407A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Judul';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5, // Tinggi textarea berdasarkan jumlah baris
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan deskripsi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Pilih Gambar'),
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size(350, 50),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFFEC407A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size(350, 55),
                ),
                child: Text(
                  'Kirim',
                  style: GoogleFonts.inter(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
