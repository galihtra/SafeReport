import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
      SnackBar(content: Text('Article deleted')),
    );
  }

  Future<void> _deleteArticleWithoutImage(String id) async {
    // Delete article from Firestore
    await _firestore.collection('articles').doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Article deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Articles'),
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

              return ListTile(
                leading: data['image_url'] != null
                    ? Image.network(data['image_url'])
                    : Icon(Icons.image, size: 50),
                title: Text(data['title']),
                subtitle: Text(data['description']),
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
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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
        title: Text('Add Article'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            ElevatedButton(
              child: Text('Choose Image'),
              onPressed: _pickImage,
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: _submit,
            ),
          ],
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
        title: Text('Update Article'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            ElevatedButton(
              child: Text('Choose Image'),
              onPressed: _pickImage,
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
