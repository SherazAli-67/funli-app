import 'package:flutter/material.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';
import '../models/user_model.dart';
import '../res/app_textstyles.dart';
import '../services/user_service.dart';
import 'loading_widget.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: UserService.getCurrentUserStream(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == .waiting) {
            return LoadingWidget();
          } else if (snapshot.hasData && snapshot.data != null) {
            UserModel user = snapshot.requireData;
            return Row(
              spacing: 10,
              children: [
                ProfilePictureWidget(profilePicture: user.profilePicture, radius: 25,),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text("${getGreeting()},", style: AppTextStyles.tileTitleTextStyle.copyWith(fontWeight: .w500)),
                    Text(user.userName, style: AppTextStyles.tileTitleTextStyle),
                  ],
                )

              ],
            );
          }
          return Text("User not found");
        });

  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else if (hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }
}