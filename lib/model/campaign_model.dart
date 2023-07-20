import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_report/model/user_model.dart';

class Campaign {
  String id;
  String title;
  String description;
  String adminId;
  List<UserModel> participants;
  String imageUrl;
  Timestamp dateTime;
  String? zoomLink;
  String nameSpeaker;
  String place;
  String meet;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.adminId,
    required this.participants,
    required this.imageUrl,
    required this.dateTime,
    this.zoomLink,
    required this.nameSpeaker,
    required this.place,
    required this.meet,
  });

  Campaign.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        title = snapshot['title'],
        description = snapshot['description'],
        adminId = snapshot['adminId'],
        zoomLink = snapshot['zoomLink'],
        nameSpeaker = snapshot['nameSpeaker'],
        meet = snapshot['meet'],
        place = snapshot['place'],
        participants = List<UserModel>.from(
          (snapshot['participants'] ?? []).map(
            (participant) => UserModel.fromMap(participant),
          ),
        ),
        imageUrl = snapshot['imageUrl'],
        dateTime = snapshot['dateTime'] is Timestamp
            ? snapshot['dateTime']
            : Timestamp.fromDate(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id, // tambahkan baris ini
        'title': title,
        'description': description,
        'adminId': adminId,
        'participants': participants.map((user) => user.toMap()).toList(),
        'imageUrl': imageUrl,
        'dateTime': dateTime,
        'zoomLink': zoomLink,
        'nameSpeaker': nameSpeaker,
        'place': place,
        'meet': meet,
      };
}
