import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';

class ProfileSettingsPage extends StatelessWidget{
  const ProfileSettingsPage({super.key, required UserModel currentUser}) : _currentUser = currentUser;
  final UserModel _currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Make Some Changes', style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
      ),
      body: SafeArea(child: Column(
        children: [
          ListTile(
            leading: ProfilePictureWidget(profilePicture: _currentUser.profilePicture),
            title: Text(_currentUser.userName, style: AppTextStyles.tileTitleTextStyle,),
            subtitle: Text("${getAgeByDOB(_currentUser.dob!)}, ${_currentUser.gender}"),
            trailing: IconButton(onPressed: (){}, icon: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: AppGradients.primaryGradient,

                ),
                child: Icon(Icons.edit, color: Colors.white,)
            )),
          )
        ],
      )),
    );
  }

  int getAgeByDOB(DateTime dob){
    int currentYear = DateTime.now().year;
    int dobYear = dob.year;
    debugPrint("DOB year: ${dob.toIso8601String()}");
    return currentYear - dobYear;
  }
}