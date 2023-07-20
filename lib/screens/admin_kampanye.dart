import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/model/campaign_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:safe_report/model/certificate_model.dart';
import 'package:safe_report/model/user_model.dart';

class KampanyeScreen extends StatefulWidget {
  const KampanyeScreen({Key? key}) : super(key: key);

  @override
  _KampanyeScreenState createState() => _KampanyeScreenState();
}

class _KampanyeScreenState extends State<KampanyeScreen> {
  final CollectionReference campaignsRef =
      FirebaseFirestore.instance.collection('campaigns');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kampanye'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: campaignsRef.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Campaign campaign = Campaign.fromSnapshot(document);
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(campaign.title),
                  subtitle: Text(campaign.description),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      campaign.imageUrl,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailKampanye(campaign: campaign),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BuatKampanye()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class BuatKampanye extends StatefulWidget {
  const BuatKampanye({Key? key}) : super(key: key);

  @override
  _BuatKampanyeState createState() => _BuatKampanyeState();
}

class _BuatKampanyeState extends State<BuatKampanye> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  File? _selectedImage;

  void _buatKampanye() async {
    final String judul = _judulController.text;
    final String deskripsi = _deskripsiController.text;

    final User? user = FirebaseAuth.instance.currentUser;
    final String adminId = user?.uid ?? '';

    if (_selectedImage != null) {
      final String imageName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('campaign_images')
          .child(imageName);

      final TaskSnapshot taskSnapshot =
          await storageReference.putFile(_selectedImage!);
      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      final Campaign newCampaign = Campaign(
        id: '',
        title: judul,
        description: deskripsi,
        adminId: adminId,
        participants: [],
        imageUrl: imageUrl,
      );

      final CollectionReference campaignsRef =
          FirebaseFirestore.instance.collection('campaigns');

      final DocumentReference docRef =
          await campaignsRef.add(newCampaign.toJson());
      final String campaignId = docRef.id;

      newCampaign.id = campaignId;
      await docRef.update({'id': campaignId});

      Navigator.pop(context);
    }
  }

  Future<void> _ambilGambar() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Buat Kampanye",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Judul',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _judulController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul kampanye',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _deskripsiController,
              decoration: InputDecoration(
                hintText: 'Masukkan deskripsi kampanye',
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            Text(
              'Pilih Gambar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: _ambilGambar,
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey,
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                    ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buatKampanye,
              child: Text('Buat Kampanye'),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Detail
class DetailKampanye extends StatefulWidget {
  final Campaign campaign;

  const DetailKampanye({Key? key, required this.campaign}) : super(key: key);

  @override
  _DetailKampanyeState createState() => _DetailKampanyeState();
}

class _DetailKampanyeState extends State<DetailKampanye> {
  Map<String, bool> _certificateStatus = {};

  @override
  void initState() {
    super.initState();
    _checkCertificateStatus();
  }

  Future<void> _checkCertificateStatus() async {
    try {
      for (var participant in widget.campaign.participants) {
        var docRef =
            FirebaseFirestore.instance.collection('users').doc(participant.uid);
        var doc = await docRef.get();
        var user = UserModel.fromMap(doc.data());
        _certificateStatus[participant.uid] = user.certificates
                ?.any((cert) => cert.campaignId == widget.campaign.id) ??
            false;
      }
    } catch (e) {
      print("Error: $e");
      // handle error properly, i.e show error message to user
    }
    setState(() {}); // Rebuild UI with new _certificateStatus
  }

  void _ambilDanUploadSertifikat(UserModel participant) async {
    final picker = ImagePicker();
    final pickedCertificate =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedCertificate != null) {
      final File selectedCertificate = File(pickedCertificate.path);

      final String certificateName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('certificate_images')
          .child(certificateName);

      final TaskSnapshot taskSnapshot =
          await storageReference.putFile(selectedCertificate);
      final certificateUrl = await taskSnapshot.ref.getDownloadURL();

      final Certificate newCertificate = Certificate(
        id: '', // An empty string as placeholder
        campaignId: widget.campaign.id,
        certificateUrl: certificateUrl,
      );

      final CollectionReference certificatesCollection =
          FirebaseFirestore.instance.collection('certificates');
      final docRef = await certificatesCollection.add(newCertificate.toMap());

      newCertificate.id =
          docRef.id; // Update the certificate id with the generated id

      participant.certificates = participant.certificates ?? [];
      participant.certificates!.add(newCertificate);

      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(participant.uid);
      await userDocRef.update({
        'certificates': FieldValue.arrayUnion([newCertificate.toMap()]),
      });

      setState(() {
        _certificateStatus[participant.uid] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final participants = [...widget.campaign.participants]; // make a copy
    participants.sort((a, b) {
      if ((_certificateStatus[a.uid] ?? false) &&
          !(_certificateStatus[b.uid] ?? false)) {
        return 1;
      }
      if (!(_certificateStatus[a.uid] ?? false) &&
          (_certificateStatus[b.uid] ?? false)) {
        return -1;
      }
      return 0;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kampanye'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.campaign.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Image.network(widget.campaign.imageUrl),
            SizedBox(height: 16),
            Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.campaign.description),
            SizedBox(height: 16),
            Text(
              'Partisipan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...participants.map(
              (participant) => ListTile(
                leading: Icon(Icons.person),
                title: Text(participant.name),
                trailing: ElevatedButton(
                  onPressed: () => _ambilDanUploadSertifikat(participant),
                  child: Text(_certificateStatus[participant.uid] ?? false
                      ? 'Sudah Upload'
                      : 'Upload Sertifikat'),
                  style: ElevatedButton.styleFrom(
                    primary: _certificateStatus[participant.uid] ?? false
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
