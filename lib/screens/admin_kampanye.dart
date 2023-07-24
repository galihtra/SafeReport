import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:safe_report/model/campaign_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:safe_report/model/certificate_model.dart';
import 'package:safe_report/model/user_model.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class KampanyeScreen extends StatefulWidget {
  const KampanyeScreen({Key? key}) : super(key: key);

  @override
  _KampanyeScreenState createState() => _KampanyeScreenState();
}

class _KampanyeScreenState extends State<KampanyeScreen> {
  final CollectionReference campaignsRef =
      FirebaseFirestore.instance.collection('campaigns');

  bool isAppointmentExpired(DateTime dateTime) {
    final now = DateTime.now();
    return now.isAfter(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Kampanye',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: campaignsRef.orderBy('dateTime').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<Campaign> campaigns = snapshot.data!.docs
              .map((document) => Campaign.fromSnapshot(document))
              .toList();

          campaigns.sort((a, b) {
            final aExpired = isAppointmentExpired(a.dateTime.toDate());
            final bExpired = isAppointmentExpired(b.dateTime.toDate());

            if (aExpired && !bExpired) {
              return 1;
            } else if (!aExpired && bExpired) {
              return -1;
            } else {
              return a.dateTime.compareTo(b.dateTime);
            }
          });

          return ListView.builder(
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              Campaign campaign = campaigns[index];
              final bool isExpired =
                  isAppointmentExpired(campaign.dateTime.toDate());

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          campaign.title,
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              color: Color(0xFFEC407A),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isExpired)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Selesai',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    campaign.description.length > 120
                        ? '${campaign.description.substring(0, 120)}...'
                        : campaign.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Color(0xFF667085),
                    ),
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      campaign.imageUrl,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  ),
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
            },
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
        backgroundColor: Color(0xFFEC407A),
      ),
    );
  }
}

// Halaman Buat Kampanye
class BuatKampanye extends StatefulWidget {
  @override
  _BuatKampanyeState createState() => _BuatKampanyeState();
}

class _BuatKampanyeState extends State<BuatKampanye> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _linkZoomController = TextEditingController();
  final TextEditingController _nameSpeakerController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedTime = DateTime.now();

  String? _selectedMeet;

  final List<String> _meetOptions = ['luring', 'daring'];

  File? _selectedImage;

  void _buatKampanye() async {
    final String judul = _judulController.text;
    final String deskripsi = _deskripsiController.text;
    final String zoomLink = _linkZoomController.text;
    final String nameSpeaker = _nameSpeakerController.text;
    final String place = _placeController.text;
    final User? user = FirebaseAuth.instance.currentUser;
    final String adminId = user?.uid ?? '';

    if (_selectedImage != null && _selectedMeet != null) {
      final String imageName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('campaign_images')
          .child(imageName);

      final TaskSnapshot taskSnapshot =
          await storageReference.putFile(_selectedImage!);
      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      final Timestamp dateTime = Timestamp.fromDate(DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ));

      final Campaign newCampaign = Campaign(
        id: '',
        title: judul,
        description: deskripsi,
        adminId: adminId,
        participants: [],
        imageUrl: imageUrl,
        dateTime: dateTime,
        zoomLink: zoomLink.isNotEmpty ? zoomLink : null, // zoomLink boleh null
        nameSpeaker: nameSpeaker,
        place: place,
        meet: _selectedMeet!,
      );

      try {
        final CollectionReference campaignsRef =
            FirebaseFirestore.instance.collection('campaigns');

        final DocumentReference docRef =
            await campaignsRef.add(newCampaign.toJson());
        final String campaignId = docRef.id;

        newCampaign.id = campaignId;
        await docRef.update({'id': campaignId});

        Navigator.pop(context);
      } catch (error) {
        print('Error when creating campaign: $error');
      }
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
        title: Text('Buat Kampanye Baru'),
        backgroundColor: Color(0xFFEC407A), // Merubah warna AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _deskripsiController,
              decoration: InputDecoration(
                hintText: 'Masukkan deskripsi',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _ambilGambar,
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: 100,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 200,
                      color: Colors.grey,
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                    ),
            ),
            SizedBox(height: 16),
            DatePicker(
              DateTime.now(),
              initialSelectedDate: DateTime.now(),
              selectionColor: Color(0xFFEC407A),
              selectedTextColor: Colors.white,
              onDateChange: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            TimePickerSpinner(
              is24HourMode: false,
              normalTextStyle: TextStyle(fontSize: 24, color: Colors.grey),
              highlightedTextStyle:
                  TextStyle(fontSize: 24, color: Color(0xFFEC407A)),
              spacing: 50,
              itemHeight: 80,
              isForce2Digits: true,
              onTimeChange: (time) {
                setState(() {
                  _selectedTime = time;
                });
              },
            ),
            TextField(
              controller: _linkZoomController,
              decoration: InputDecoration(
                hintText: 'Masukkan link Zoom',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameSpeakerController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama pembicara',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                hintText: 'Masukkan lokasi pertemuan',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField(
              hint: Text('Pilih metode pertemuan'),
              value: _selectedMeet,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMeet = newValue;
                });
              },
              items: _meetOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buatKampanye,
              child: Text('Buat Kampanye'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(350, 55),
                primary: Color(0xFFEC407A), // Merubah warna button
                textStyle: TextStyle(fontSize: 20), // Merubah ukuran teks
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                ),
              ),
            ),
            const SizedBox(
              height: 20,
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

    if (mounted) {
      setState(() {}); // Rebuild UI with new _certificateStatus
    }
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

  void _navigateToUpdate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateKampanye(campaign: widget.campaign),
      ),
    );
  }

  Future<void> _hapusKampanye() async {
    try {
      await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(widget.campaign.id)
          .delete();

      Navigator.pop(context);
    } catch (e) {
      print("Error when deleting campaign: $e");
      // handle error properly, i.e show error message to user
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
        backgroundColor: Color(0xFFEC407A),
        title: Text('Detail Kampanye'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _navigateToUpdate,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _hapusKampanye,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              Image.network(
                widget.campaign.imageUrl,
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
              Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(widget.campaign.description),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFFEC407A),
                      ),
                      SizedBox(width: 5),
                      Text(
                        DateFormat('HH:mm')
                                .format(widget.campaign.dateTime.toDate()) +
                            ' WIB',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 33, 33, 33),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 14,
                        color: Color(0xFFEC407A),
                      ),
                      SizedBox(width: 5),
                      Text(
                        DateFormat('dd MMMM yyyy')
                            .format(widget.campaign.dateTime.toDate()),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Nama Pembicara: ",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                widget.campaign.nameSpeaker,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Detail Tempat: ",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                widget.campaign.place,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Link Zoom: ",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                widget.campaign.zoomLink?.isEmpty ?? true
                    ? 'Tidak ada Zoom'
                    : widget.campaign.zoomLink!,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
      ),
    );
  }
}

// Halaman Update
class UpdateKampanye extends StatefulWidget {
  final Campaign campaign;

  const UpdateKampanye({Key? key, required this.campaign}) : super(key: key);

  @override
  _UpdateKampanyeState createState() => _UpdateKampanyeState();
}

class _UpdateKampanyeState extends State<UpdateKampanye> {
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TextEditingController _linkZoomController;
  late TextEditingController _nameSpeakerController;
  late TextEditingController _placeController;

  late DateTime _selectedDate;
  late DateTime _selectedTime;

  String? _selectedMeet;
  File? _selectedImage;

  final List<String> _meetOptions = ['luring', 'daring'];

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.campaign.title);
    _deskripsiController =
        TextEditingController(text: widget.campaign.description);
    _linkZoomController =
        TextEditingController(text: widget.campaign.zoomLink ?? '');
    _nameSpeakerController =
        TextEditingController(text: widget.campaign.nameSpeaker);
    _placeController = TextEditingController(text: widget.campaign.place);
    _selectedDate = widget.campaign.dateTime.toDate();
    _selectedTime = widget.campaign.dateTime.toDate();
    if (_meetOptions.contains(widget.campaign.meet)) {
      _selectedMeet = widget.campaign.meet;
    } else {
      _selectedMeet = null;
    }
  }

  bool isSameDateTime(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day &&
        dateTime1.hour == dateTime2.hour &&
        dateTime1.minute == dateTime2.minute;
  }

  Future<void> _updateKampanye() async {
    final String judul = _judulController.text;
    final String deskripsi = _deskripsiController.text;
    final String zoomLink = _linkZoomController.text;
    final String nameSpeaker = _nameSpeakerController.text;
    final String place = _placeController.text;
    final User? user = FirebaseAuth.instance.currentUser;
    final String adminId = user?.uid ?? '';

    String imageUrl = widget.campaign.imageUrl;

    if (_selectedImage != null) {
      final String imageName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('campaign_images')
          .child(imageName);

      final TaskSnapshot taskSnapshot =
          await storageReference.putFile(_selectedImage!);
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    }

    Timestamp dateTime = widget.campaign.dateTime;

    final DateTime oldDateTime = widget.campaign.dateTime.toDate();
    final DateTime newDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (!isSameDateTime(oldDateTime, newDateTime)) {
      dateTime = Timestamp.fromDate(newDateTime);
    }

    if (_selectedMeet != null) {
      final Campaign updatedCampaign = Campaign(
        id: widget.campaign.id,
        title: judul,
        description: deskripsi,
        adminId: adminId,
        participants: widget.campaign.participants,
        imageUrl: imageUrl,
        dateTime: dateTime,
        zoomLink: zoomLink.isNotEmpty ? zoomLink : null,
        nameSpeaker: nameSpeaker,
        place: place,
        meet: _selectedMeet!,
      );

      try {
        final DocumentReference campaignDocRef = FirebaseFirestore.instance
            .collection('campaigns')
            .doc(widget.campaign.id);

        if (judul != widget.campaign.title ||
            deskripsi != widget.campaign.description ||
            zoomLink != (widget.campaign.zoomLink ?? '') ||
            nameSpeaker != widget.campaign.nameSpeaker ||
            place != widget.campaign.place ||
            _selectedMeet != widget.campaign.meet ||
            imageUrl != widget.campaign.imageUrl ||
            !isSameDateTime(oldDateTime, newDateTime)) {
          await campaignDocRef.update(updatedCampaign.toJson());
        }
      } catch (error) {
        print('Error when updating campaign: $error');
      } finally {
        Navigator.pop(context);
      }
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
        title: Text('Update Kampanye'),
        backgroundColor: Color(0xFFEC407A), // Merubah warna AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _deskripsiController,
              decoration: InputDecoration(
                hintText: 'Masukkan deskripsi',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _ambilGambar,
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: 100,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 200,
                      color: Colors.grey,
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                    ),
            ),
            SizedBox(height: 16),
            DatePicker(
              DateTime.now(),
              initialSelectedDate: DateTime.now(),
              selectionColor: Color(0xFFEC407A),
              selectedTextColor: Colors.white,
              onDateChange: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            TimePickerSpinner(
              is24HourMode: false,
              normalTextStyle: TextStyle(fontSize: 24, color: Colors.grey),
              highlightedTextStyle:
                  TextStyle(fontSize: 24, color: Color(0xFFEC407A)),
              spacing: 50,
              itemHeight: 80,
              isForce2Digits: true,
              onTimeChange: (time) {
                setState(() {
                  _selectedTime = time;
                });
              },
            ),
            TextField(
              controller: _linkZoomController,
              decoration: InputDecoration(
                hintText: 'Masukkan link Zoom',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameSpeakerController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama pembicara',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                hintText: 'Masukkan lokasi pertemuan',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField(
              hint: Text('Pilih metode pertemuan'),
              value: _selectedMeet,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMeet = newValue;
                });
              },
              items: _meetOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                  borderSide: BorderSide(
                      color: Color(0xFFEC407A)), // Merubah warna border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Merubah fill color
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateKampanye,
              child: Text('Update Kampanye'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(350, 55),
                primary: Color(0xFFEC407A), // Merubah warna button
                textStyle: TextStyle(fontSize: 20), // Merubah ukuran teks
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Menambahkan border radius
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
