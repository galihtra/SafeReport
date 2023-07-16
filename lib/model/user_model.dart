class UserModel {
  String uid;
  String name;
  String email;
  String gender;
  bool isAdmin;
  String? bio;
  String? image_url;
  String? prodi;
  String? no_telp;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.gender,
    this.isAdmin = false,
    this.image_url,
    this.bio,
    this.prodi,
    this.no_telp,
  });

  factory UserModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw Exception('Invalid user data');
    }
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      image_url: map['image_url'],
      bio: map['bio'],
      prodi: map['prodi'],
      no_telp: map['no_telp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'gender': gender,
      'isAdmin': isAdmin,
      'image_url': image_url,
      'bio': bio,
      'prodi': prodi,
      'no_telp': no_telp,
    };
  }
}
