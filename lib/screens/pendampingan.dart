import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:safe_report/model/Appointment.dart';

class Pendampingan extends StatefulWidget {
  const Pendampingan({Key? key}) : super(key: key);

  @override
  _PendampinganState createState() => _PendampinganState();
}

class _PendampinganState extends State<Pendampingan> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pendamping",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('isAdmin', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return InkWell(
                  onTap: () {
                    // Navigasi ke halaman detail item
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPendamping(data: data),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: (data['image_url'] != null)
                        ? CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(data['image_url']),
                          )
                        : CircleAvatar(
                            radius: 25,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            backgroundColor: Color(0xFFEC407A),
                          ),
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 1),
                      child: Text(
                        data['name'] ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text(
                            data['gender'] ?? '',
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            '(${data['prodi'] ?? ''})',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF98A2B3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

// Detail Pendamping
class DetailPendamping extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPendamping({required this.data});

  @override
  _DetailPendampingState createState() => _DetailPendampingState();
}

class _DetailPendampingState extends State<DetailPendamping> {
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedTime = DateTime.now();
  final TextEditingController locationDetailController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getCompanionId() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isAdmin', isEqualTo: true)
        .get();

    final documents = querySnapshot.docs;
    if (documents.isNotEmpty) {
      return documents.first.id; // id of the first admin user found
    }

    throw Exception('No admin user found');
  }

  Future<void> createAppointment(AppointmentModel appointment) {
    return FirebaseFirestore.instance
        .collection('appointments')
        .add(appointment.toMap());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(''),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          child: Stack(
            children: [
              Container(
                height: size.height * 0.35,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: (widget.data['image_url'] != null)
                        ? NetworkImage(widget.data['image_url'])
                        : AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: size.height * 0.75,
                  width: size.width,
                  margin: EdgeInsets.only(top: size.height * 0.3),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 10,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                widget.data['name'] ?? '',
                                style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF263257)),
                              ),
                            ),
                            Text(
                              widget.data['gender'] ?? '',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF667085)),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          widget.data['bio'] ?? '',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF667085)),
                        ),
                        const SizedBox(height: 20),
                        // Jadwal
                        Text(
                          'Jadwal',
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF263257)),
                        ),
                        const SizedBox(height: 10),
                        DatePicker(
                          DateTime.now(),
                          initialSelectedDate: DateTime.now(),
                          selectionColor: Color(0xFFEC407A),
                          selectedTextColor: Colors.white,
                          onDateChange: (date) {
                            // New date selected
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        // Jam
                        Text(
                          'Jam',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF263257),
                          ),
                        ),
                        TimePickerSpinner(
                          is24HourMode: false,
                          normalTextStyle:
                              TextStyle(fontSize: 24, color: Colors.grey),
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
                        const SizedBox(height: 20),
                        Text(
                          'Detail Tempat',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF263257),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: locationDetailController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan detail tempat',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              final User? user = _auth.currentUser;
                              final String userId =
                                  user != null ? user.uid : '';

                              try {
                                final companionId = await getCompanionId();
                                final appointment = AppointmentModel(
                                  userId: userId,
                                  companionId: companionId,
                                  date: DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month,
                                      _selectedDate.day,
                                      _selectedTime.hour,
                                      _selectedTime.minute),
                                  locationDetail: locationDetailController.text,
                                );
                                createAppointment(appointment)
                                    .then((_) => print('Appointment created'))
                                    .catchError((error) => print(
                                        'Failed to create appointment: $error'));
                              } catch (e) {
                                print('Failed to get companionId: $e');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: const Color(0xFFEC407A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              minimumSize: const Size(350, 55),
                            ),
                            child: Text(
                              'BUAT JANJI TEMU',
                              style: GoogleFonts.inter(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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
