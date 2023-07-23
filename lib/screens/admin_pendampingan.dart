import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/model/Appointment.dart';
import 'package:safe_report/model/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPendampingan extends StatefulWidget {
  final String? companionId;

  AdminPendampingan({Key? key, required this.companionId}) : super(key: key);

  @override
  _AdminPendampinganState createState() => _AdminPendampinganState();
}

class _AdminPendampinganState extends State<AdminPendampingan> {
  Future<List<AppointmentModel>> getAppointments() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('companionId', isEqualTo: widget.companionId)
        .get();

    List<AppointmentModel> appointments =
        snapshot.docs.map<AppointmentModel>((doc) {
      return AppointmentModel.fromFirestore(doc);
    }).toList();

    // Sorting appointments based on date and time, with expired ones at the bottom and upcoming ones at the top
    appointments.sort((a, b) {
      final now = DateTime.now();
      final isExpiredA = now.isAfter(a.date);
      final isExpiredB = now.isAfter(b.date);

      if (isExpiredA && isExpiredB) {
        return a.date
            .compareTo(b.date); // Sort by date for expired appointments
      } else if (isExpiredA) {
        return 1; // Push expired appointments to the bottom
      } else if (isExpiredB) {
        return -1; // Push upcoming appointments to the top
      } else {
        return a.date
            .compareTo(b.date); // Sort by date for upcoming appointments
      }
    });

    return appointments;
  }

  Future<UserModel> getUser(String uid) async {
    final DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapshot.exists) {
      final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return UserModel.fromMap(data);
    } else {
      throw Exception('User not found');
    }
  }

  Future<void> reschedule(
      BuildContext context, AppointmentModel appointment) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: appointment.date.isBefore(DateTime.now())
          ? DateTime.now()
          : appointment.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(appointment.date),
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

        // Menampilkan dialog berhasil mengubah jadwal
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8.0),
                  Text('Berhasil Mengubah Jadwal'),
                ],
              ),
              content: Text('Jadwal janji temu berhasil diubah.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        // Refresh halaman setelah berhasil mengubah jadwal
        setState(() {});
      }
    }
  }

  bool isAppointmentExpired(DateTime date) {
    final now = DateTime.now();
    return now.isAfter(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Janji Temu Pendampingan',
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
                final bool isExpired = isAppointmentExpired(appointment.date);

                return FutureBuilder<UserModel>(
                  future: getUser(appointment.userId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final user = snapshot.data!;
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
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'JANJI TEMU',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFEC407A),
                                            ),
                                          ),
                                        ),
                                        if (isExpired)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
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
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              ListTile(
                                title: Text(user.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('HH:mm, d MMMM yyyy')
                                          .format(appointment.date),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isExpired
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Tempat: ${appointment.locationDetail}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF98A2B3),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: isExpired
                                    ? null
                                    : ElevatedButton.icon(
                                        onPressed: () =>
                                            reschedule(context, appointment),
                                        icon: Icon(Icons.schedule),
                                        label: Text('Reschedule'),
                                        style: ElevatedButton.styleFrom(
                                          primary: Color(0xFFEC407A),
                                        ),
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
