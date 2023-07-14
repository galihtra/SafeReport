import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_report/model/Appointment.dart';
import 'package:safe_report/model/user_model.dart';

class AdminPendampingan extends StatelessWidget {
  const AdminPendampingan({Key? key}) : super(key: key);

  Future<List<AppointmentModel>> getAppointments() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('appointments').get();

    List<AppointmentModel> appointments =
        snapshot.docs.map<AppointmentModel>((doc) {
      return AppointmentModel.fromFirestore(doc);
    }).toList();

    return appointments;
  }

  Future<UserModel> getUser(String uid) async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      return UserModel(
        uid: uid,
        name: data['name'],
        email: data['email'],
        gender: data['gender'],
        isAdmin: data['isAdmin'],
      );
    }

    throw Exception('User not found');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Janji Temu'),
      ),
      body: FutureBuilder<List<AppointmentModel>>(
        future: getAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final appointments = snapshot.data!;
            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return FutureBuilder<UserModel>(
                  future: getUser(appointment.userId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final user = snapshot.data!;
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(
                          'Janji temu: ${appointment.date} \nTempat: ${appointment.locationDetail}',
                        ),
                        onTap: () => reschedule(context, appointment),
                      );
                    }

                    if (snapshot.hasError) {
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
