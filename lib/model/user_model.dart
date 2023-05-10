class User {
  String? uid;
  String? name;
  String? email;
  String? gender;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.gender,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      gender: data['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'gender': gender,
    };
  }
}
