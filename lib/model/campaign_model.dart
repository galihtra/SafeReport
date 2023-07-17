import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CampaignType { luring, online }

class CampaignModel {
  final String id;
  final String title;
  final String time; // Ubah tipe data TimeOfDay menjadi String
  final DateTime schedule;
  final String description;
  final String speakerName;
  final String location;
  final String zoomLink;
  final bool hasCertificate;
  final CampaignType type;
  final String imagePath;

  CampaignModel({
    required this.id,
    required this.title,
    required this.time,
    required this.schedule,
    required this.description,
    required this.speakerName,
    required this.location,
    required this.zoomLink,
    required this.hasCertificate,
    required this.type,
    required this.imagePath,
  });

  factory CampaignModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return CampaignModel(
      id: snapshot.id,
      title: data['title'],
      time: data['time'], // Ubah pengambilan data 'time'
      schedule: data['schedule'].toDate(),
      imagePath: data['imagePath'],
      description: data['description'],
      speakerName: data['speakerName'],
      location: data['location'],
      zoomLink: data['zoomLink'],
      hasCertificate: data['hasCertificate'],
      type: CampaignType.values.firstWhere(
        (type) => type.toString() == 'CampaignType.${data['type']}',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': time, // Ubah penyimpanan data 'time'
      'schedule': Timestamp.fromDate(schedule),
      'description': description,
      'speakerName': speakerName,
      'location': location,
      'zoomLink': zoomLink,
      'hasCertificate': hasCertificate,
      'type': type.toString().split('.').last,
    };
  }
}
