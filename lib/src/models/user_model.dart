class UserModel {
  final String userID;
  final String userName;
  final String email;
  final DateTime? dob;
  final String? mood;
  final List<String> interests;
  final String? bio;
  final String? profilePicture;
  final String? gender;
  UserModel({
    required this.userID,
    required this.userName,
    required this.email,
    this.dob,
    this.mood,
    this.bio,
    this.profilePicture,
    this.gender,
    List<String>? interests,
  }) : interests = interests ?? [];

  Map<String, dynamic> toMap() {
    return {
      "userID" : userID,
      'userName': userName,
      'email': email,
      'dob': dob?.toIso8601String(),
      'interests': interests,
      'mood' : mood,
      'bio' : bio,
      'profilePicture' : profilePicture,
      'gender' : gender
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      profilePicture: map['profilePicture'],
      bio: map['bio'],
      mood: map['mood'],
      dob: map['dob'] != null ? DateTime.tryParse(map['dob']) : null,
      interests: List<String>.from(map['interests'] ?? []),
      gender: map['gender']
    );
  }
}