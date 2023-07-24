import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  String? id;
  String userId;
  String companionId;
  DateTime date;
  String locationDetail;

  AppointmentModel({this.id, required this.userId, required this.companionId, required this.date, required this.locationDetail});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'companionId': companionId,
      'date': Timestamp.fromDate(date),
      'locationDetail': locationDetail,
    };
  }

  static AppointmentModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppointmentModel(
      id: doc.id, // Ini adalah id dokumen
      userId: data['userId'],
      companionId: data['companionId'],
      date: (data['date'] as Timestamp).toDate(),
      locationDetail: data['locationDetail'],
    );
  }
}