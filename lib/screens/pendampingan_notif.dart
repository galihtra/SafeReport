import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/model/Appointment.dart';
import 'package:safe_report/model/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PendampinganNotif extends StatefulWidget {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  PendampinganNotif({Key? key}) : super(key: key);

  @override
  _PendampinganNotifState createState() => _PendampinganNotifState();
}

class _PendampinganNotifState extends State<PendampinganNotif> {
  Future<List<AppointmentModel>> getAppointments() async {
    if (widget.userId == null) throw Exception("User not logged in");

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: widget.userId)
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
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 30,
                  child: Icon(
                    Icons.calendar_month,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Anda yakin ingin menjadwalkan\nulang janji temu?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 100,
                        height: 45,
                        child: ElevatedButton(
                          child: Text(
                            'Batal',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFF1F1F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: SizedBox(
                        width: 100,
                        height: 45,
                        child: ElevatedButton(
                          child: Text(
                            'Yakin',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFEC407A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
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
  }

  bool isAppointmentExpired(DateTime date) {
    final now = DateTime.now();
    return now.isAfter(date);
  }

  @override
  Widget build(BuildContext context) {
    print('User ID: ${widget.userId}'); // Debug User ID

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
                final bool isExpired = isAppointmentExpired(appointment.date);

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
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'JANJI TEMU PENDAMPINGAN',
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Row(
                                  children: [
                                    if (companion.image_url != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          companion.image_url!,
                                          fit: BoxFit.cover,
                                          height: 65.0,
                                          width: 70.0,
                                          errorBuilder: (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                            return Image.asset(
                                              'assets/images/default_avatar.png',
                                              fit: BoxFit.cover,
                                              height: 65.0,
                                              width: 70.0,
                                            );
                                          },
                                        ),
                                      )
                                    else
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          'assets/images/default_avatar.png',
                                          height: 65.0,
                                          width: 70.0,
                                        ),
                                      ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            companion.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            companion.gender,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '(${companion.prodi ?? ''})',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xFF98A2B3),
                                            ),
                                          ),
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
                                            color: isExpired
                                                ? Colors.grey
                                                : Colors.red,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd MMMM yyyy')
                                              .format(appointment.date),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isExpired
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
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
                                        fontSize: 16,
                                      ),
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
                                        if (!isExpired)
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => reschedule(
                                                  context, appointment),
                                              style: ElevatedButton.styleFrom(
                                                primary:
                                                    const Color(0xFFEC407A),
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
                                        if (!isExpired) SizedBox(width: 8),
                                        if (!isExpired)
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
                                                primary:
                                                    const Color(0xFF4CAF50),
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
