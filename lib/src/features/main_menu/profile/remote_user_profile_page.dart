import 'package:flutter/material.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile.dart';

class RemoteUserProfilePage extends StatelessWidget{
  const RemoteUserProfilePage({
    super.key,
    required String userID,
    String? userName,
    String? profilePicture,
  }): _userID = userID, _userName = userName, _profilePicture = profilePicture;

  final String _userID;
  final String? _userName;
  final String? _profilePicture;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          RemoteUserProfileInfoWidget(userID: _userID, userName: _userName, profilePicture: _profilePicture, isFromProfilePage: true,)
        ],
      )
    );
  }
}