import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:safe_report/screens/report_success.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PelaporanForm extends StatefulWidget {
  @override
  _PelaporanFormState createState() => _PelaporanFormState();
}

class _PelaporanFormState extends State<PelaporanForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _namaPelakuController = TextEditingController();
  final TextEditingController _noTelpPelakuController = TextEditingController();
  final TextEditingController _deskripsiPelakuController =
      TextEditingController();
  final TextEditingController _tanggalKejadianController =
      TextEditingController();
  final TextEditingController _tempatKejadianController =
      TextEditingController();
  final TextEditingController _kronologiKejadianController =
      TextEditingController();
  final TextEditingController _namaSaksiController = TextEditingController();
  final TextEditingController _noTelpSaksiController = TextEditingController();
  final TextEditingController _keteranganSaksiController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _pickedImage;
  DateTime? _selectedDate;
  String gender = 'Perempuan';
  String? jurusan;
  String? prodi;
  List<String> jurusanOptions = [
    'Teknik Informatika',
    'Teknik Mesin',
    'Teknik Elektro',
    'Manajemen Bisnis'
  ];
  Map<String, List<String>> programStudyOptions = {
    'Teknik Informatika': ['Informatika', 'Sistem Informasi'],
    'Teknik Mesin': ['Teknik Mesin 1', 'Teknik Mesin 2'],
    'Teknik Elektro': ['Teknik Elektro 1', 'Teknik Elektro 2'],
    'Manajemen Bisnis': ['Manajemen Bisnis 1', 'Manajemen Bisnis 2'],
  };
  String? kelas;
  String? jenisKasus;
  String? bentukKasus;
  String genderPelaku = 'Laki-laki';
  String? jurusanPelaku;
  String? prodiPelaku;
  String? kelasPelaku;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.getImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _tanggalKejadianController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  final firebase_storage.FirebaseStorage _storage =
    firebase_storage.FirebaseStorage.instance;
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_pickedImage != null) {
        final firebase_storage.Reference storageRef = _storage
      .ref('articles/images/${_namaController.text}');
    final firebase_storage.UploadTask uploadTask =
        storageRef.putFile(_pickedImage!);
    final firebase_storage.TaskSnapshot snapshot =
        await uploadTask.whenComplete(() {});
    imageUrl = await snapshot.ref.getDownloadURL();
      }

      if (_formKey.currentState!.validate()) {
      try {
        final formData = {
          'nama': _namaController.text,
          'nim': _nimController.text,
          'noTelp': _noTelpController.text,
          'namaPelaku': _namaPelakuController.text,
          'noTelpPelaku': _noTelpPelakuController.text,
          'deskripsiPelaku': _deskripsiPelakuController.text,
          'tanggalKejadian': _tanggalKejadianController.text,
          'tempatKejadian': _tempatKejadianController.text,
          'kronologiKejadian': _kronologiKejadianController.text,
          'namaSaksi': _namaSaksiController.text,
          'noTelpSaksi': _noTelpSaksiController.text,
          'keteranganSaksi': _keteranganSaksiController.text,
          'gender': gender,
          'jurusan': jurusan,
          'prodi': prodi,
          'kelas': kelas,
          'jenisKasus': jenisKasus,
          'bentukKasus': bentukKasus,
          'genderPelaku': genderPelaku,
          'jurusanPelaku': jurusanPelaku,
          'prodiPelaku': prodiPelaku,
          'kelasPelaku': kelasPelaku,
          'bukti_pendukung':imageUrl
        };

        final firestore = FirebaseFirestore.instance;
        await firestore.collection('report').add(formData);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Form data has been successfully submitted.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReportSuccess()));
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );

        _namaController.clear();
        _nimController.clear();
        _noTelpController.clear();
        _namaPelakuController.clear();
        _noTelpPelakuController.clear();
        _deskripsiPelakuController.clear();
        _tanggalKejadianController.clear();
        _tempatKejadianController.clear();
        _kronologiKejadianController.clear();
        _namaSaksiController.clear();
        _noTelpSaksiController.clear();
        _keteranganSaksiController.clear();
        setState(() {
          gender = 'Perempuan';
          jurusan = null;
          prodi = null;
          kelas = null;
          jenisKasus = null;
          bentukKasus = null;
          genderPelaku = 'Laki-laki';
          jurusanPelaku = null;
          prodiPelaku = null;
          kelasPelaku = null;
        });
      } catch (error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred while submitting the form. Please try again.'),
            );
          },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pelaporan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Pelapor',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                      labelText: '',
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      )),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Nomor Induk Mahasiswa Pelapor',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _nimController,
                  decoration: InputDecoration(
                      labelText: '',
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      )),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Jenis Kelamin Pelapor',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      gender = newValue!;
                    });
                  },
                  items: <String>['Laki-laki', 'Perempuan']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFFCECCCC),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Jurusan Pelapor',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: jurusan,
                  decoration: InputDecoration(
                    hintText: "Pilih Jurusan",
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      jurusan = newValue!;
                      prodi = null; // Reset the selected program study
                    });
                  },
                  items: jurusanOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFFCECCCC),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Program Studi Pelapor',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: prodi,
                  decoration: InputDecoration(
                    hintText: "Pilih Program Studi",
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      prodi = newValue!;
                    });
                  },
                  items: (jurusan != null &&
                          programStudyOptions.containsKey(jurusan!))
                      ? programStudyOptions[jurusan!]!
                          .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Color(0xFFCECCCC),
                              ),
                            ),
                          );
                        }).toList()
                      : [],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Kelas Pelapor',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: kelas,
                  decoration: InputDecoration(
                    hintText: "Pilih Kelas",
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      kelas = newValue!;
                    });
                  },
                  items: <String>['A Pagi', 'B Pagi', 'A Malam', 'B Malam']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFFCECCCC),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Nomor Handphone Pelapor',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _noTelpController,
                  decoration: InputDecoration(
                      labelText: '',
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Jenis Kasus',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: jenisKasus,
                  decoration: InputDecoration(
                    hintText: 'Pilih Jenis Kasus',
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      jenisKasus = newValue!;
                    });
                  },
                  items: <String>['Pelecehan', 'Kekerasan']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFFCECCCC),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Bentuk Kasus',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: bentukKasus,
                  decoration: InputDecoration(
                    hintText: 'Pilih Bentuk Kasus',
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      bentukKasus = newValue!;
                    });
                  },
                  items: <String>['Megang Badan', 'Pembulian']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFFCECCCC),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Nama Pelaku',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _namaPelakuController,
                  decoration: InputDecoration(
                      labelText: 'Tidak perlu diisi jika tidak tau',
                      labelStyle: TextStyle(
                        color: Color(0xFFCECCCC), // Set the desired color here
                      ),
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Jenis Kelamin Pelaku',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: genderPelaku,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      genderPelaku = newValue!;
                    });
                  },
                  items: <String>['Laki-laki', 'Perempuan']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFFCECCCC),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Jurusan Pelaku',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: jurusanPelaku,
                  decoration: InputDecoration(
                    hintText: "Pilih Jurusan (Optional)",
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      jurusanPelaku = newValue!;
                      prodiPelaku = null; // Reset the selected program study
                    });
                  },
                  items: jurusanOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFFCECCCC),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Program Studi Pelaku',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: prodiPelaku,
                  decoration: InputDecoration(
                    hintText: "Pilih Program Studi",
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      prodiPelaku = newValue!;
                    });
                  },
                  items: (jurusanPelaku != null &&
                          programStudyOptions.containsKey(jurusanPelaku!))
                      ? programStudyOptions[jurusanPelaku!]!
                          .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Color(0xFFCECCCC),
                              ),
                            ),
                          );
                        }).toList()
                      : [],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Kelas Pelaku',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  value: kelasPelaku,
                  decoration: InputDecoration(
                    hintText: "Pilih Kelas (Opsional)",
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      kelasPelaku = newValue!;
                    });
                  },
                  items: <String>['A Pagi', 'B Pagi', 'A Malam', 'B Malam']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFFCECCCC),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Nomor Handphone Pelapor',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _noTelpPelakuController,
                  decoration: InputDecoration(
                      hintText: 'Tidak perlu diisi jika tidak mengetahui',
                      hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Deskripsikan Pelaku',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _deskripsiPelakuController,
                  decoration: InputDecoration(
                    labelText: '',
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    // Adjust the values as needed
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Tanggal Kejadian',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _tanggalKejadianController,
                  readOnly: true, // Make the input field read-only
                  onTap: () {
                    _selectDate(
                        context); // Call _selectDate function and pass the context
                  },
                  decoration: InputDecoration(
                    hintText: 'dd/mm/yyyy',
                    hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFFCECCCC),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Tempat Kejadian',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _tempatKejadianController,
                  decoration: InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Kronologi Kejadian',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _kronologiKejadianController,
                  decoration: InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Bukti Pendukung',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    TextFormField(
                      readOnly: true, // Make the input field read-only
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF2F2F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 60.0, horizontal: 10.0),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Add image picking functionality here
                        _pickImage();
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20.0, right: 20.0),
                        child: Image.asset(
                          'assets/images/tambah.png',
                          width: 24.0,
                          height: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Nama Saksi',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _namaSaksiController,
                  decoration: InputDecoration(
                      hintText: 'Optional',
                      hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Nomor HandPhone Saksi',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _noTelpSaksiController,
                  decoration: InputDecoration(
                      hintText: 'Optional',
                      hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Keterangan Saksi',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _keteranganSaksiController,
                  decoration: InputDecoration(
                      hintText: 'Optional',
                      hintStyle: TextStyle(color: Color(0xFFCECCCC)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      )),
                ),
                // Add other form fields here
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Kirim'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
