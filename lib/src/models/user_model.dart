enum ProfileVisibility {
  public,
  followersOfFollowers,
  followersOnly,
}

extension ProfileVisibilityExtension on ProfileVisibility {
  String get value {
    switch (this) {
      case ProfileVisibility.public:
        return 'public';
      case ProfileVisibility.followersOfFollowers:
        return 'followersOfFollowers';
      case ProfileVisibility.followersOnly:
        return 'followersOnly';
    }
  }

  static ProfileVisibility fromString(String value) {
    switch (value) {
      case 'followersOfFollowers':
        return ProfileVisibility.followersOfFollowers;
      case 'followersOnly':
        return ProfileVisibility.followersOnly;
      case 'public':
      default:
        return ProfileVisibility.public;
    }
  }
}

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
  final ProfileVisibility visibility;
  final int reelsPosted;

  UserModel({
    required this.userID,
    required this.userName,
    required this.email,
    this.dob,
    this.mood,
    this.bio,
    this.profilePicture,
    this.gender,
    this.visibility = ProfileVisibility.public,
    this.reelsPosted = 0,
    List<String>? interests,
  }) : interests = interests ?? [];

  Map<String, dynamic> toMap() {
    return {
      "userID": userID,
      "userName": userName,
      "email": email,
      "dob": dob?.toIso8601String(),
      "interests": interests,
      "mood": mood,
      "bio": bio,
      "profilePicture": profilePicture,
      "gender": gender,
      "visibility": visibility.value,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'] ?? '',
      userName: map['userName'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      profilePicture: map['profilePicture'],
      bio: map['bio'],
      mood: map['mood'],
      dob: map['dob'] != null ? DateTime.tryParse(map['dob']) : null,
      interests: List<String>.from(map['interests'] ?? []),
      gender: map['gender'],
      visibility: ProfileVisibilityExtension.fromString(map['visibility'] ?? 'public'),
      reelsPosted: map['reelsPosted'] ?? 0,
    );
  }
}