import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_report/model/user_model.dart';

class Campaign {
  String id;
  String title;
  String description;
  String adminId;
  List<UserModel> participants;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.adminId,
    required this.participants,
  });

  Campaign.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        title = snapshot['title'],
        description = snapshot['description'],
        adminId = snapshot['adminId'],
        participants = List<UserModel>.from(
          (snapshot['participants'] ?? []).map(
            (participant) => UserModel.fromMap(participant),
          ),
        );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'adminId': adminId,
        'participants': participants.map((user) => user.toMap()).toList(),
      };
}
