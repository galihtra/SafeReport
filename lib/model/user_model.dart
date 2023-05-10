class UserModel {
  String uid;
  String name;
  String email;
  String gender;

  UserModel({required this.uid, required this.name, required this.email, required this.gender});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'gender': gender,
    };
  }
}
