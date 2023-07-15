import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_report/model/Appointment.dart';
import 'package:safe_report/model/user_model.dart';

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
        title: Text('Janji Temu Saya'),
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
                      return ListTile(
                        title: Text(
                            'Janji Temu Pendampingan dengan ${companion.name}'),
                        subtitle: Text(
                          'Janji temu: ${appointment.date} \nTempat: ${appointment.locationDetail}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.schedule), //icon untuk reschedule
                          onPressed: () => reschedule(context, appointment),
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
