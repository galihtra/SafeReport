import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/model/Appointment.dart';
import 'package:safe_report/model/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PendampinganNotif extends StatelessWidget {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  PendampinganNotif({Key? key}) : super(key: key);

  Future<List<AppointmentModel>> getAppointments() async {
    if (userId == null) throw Exception("User not logged in");

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .get();

    List<AppointmentModel> appointments =
        snapshot.docs.map<AppointmentModel>((doc) {
      return AppointmentModel.fromFirestore(doc);
    }).toList();

    return appointments;
  }

  Future<UserModel> getCompanion(String companionId) async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(companionId)
        .get();

    if (snapshot.exists) {
      final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return UserModel.fromMap(data);
    } else {
      throw Exception('Companion not found');
    }
  }

  Future<void> reschedule(
      BuildContext context, AppointmentModel appointment) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointment.id)
            .update({
          'date': newDateTime,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('User ID: $userId'); // Debug User ID

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Janji Temu Saya',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<AppointmentModel>>(
        future: getAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final appointments = snapshot.data!;
            print('Janji temu: $appointments'); // Debug Appointments

            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return FutureBuilder<UserModel>(
                  future: getCompanion(appointment.companionId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final companion = snapshot.data!;
                      return Card(
                        margin: EdgeInsets.all(15),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  'JANJI TEMU PENDAMPINGAN',
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFEC407A)),
                                ),
                              ),
                              SizedBox(height: 5),
                              if (companion.image_url != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                            companion.image_url!,
                                            fit: BoxFit.cover,
                                            height: 65.0,
                                            width: 70.0),
                                      ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(companion.name,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Text(companion.gender,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey)),
                                            Text('(${companion.prodi ?? ''})',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: Color(0xFF98A2B3),
                                                )),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            DateFormat('HH:mm')
                                                .format(appointment.date),
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          ),
                                          Text(
                                            DateFormat('dd MMMM yyyy')
                                                .format(appointment.date),
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Detail Tempat:',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      appointment.locationDetail,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFF98A2B3),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => reschedule(
                                                context, appointment),
                                            style: ElevatedButton.styleFrom(
                                              primary: const Color(0xFFEC407A),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'BUAT JANJI ULANG',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              final String phoneNumber =
                                                  companion.no_telp ?? '';
                                              if (phoneNumber.isNotEmpty) {
                                                launch('tel:$phoneNumber');
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: const Color(0xFF4CAF50),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'TELEPON',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    return CircularProgressIndicator();
                  },
                );
              },
            );
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
}
