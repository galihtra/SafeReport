import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  String userId;
  String companionId;
  DateTime date;
  String locationDetail;

  AppointmentModel({required this.userId, required this.companionId, required this.date, required this.locationDetail});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'companionId': companionId,
      'date': Timestamp.fromDate(date),
      'locationDetail': locationDetail,
    };
  }
}