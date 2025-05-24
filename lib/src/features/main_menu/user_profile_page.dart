import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/features/welcome_page.dart';

class UserProfilePage extends StatelessWidget{
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(onPressed: ()async {
         await FirebaseAuth.instance.signOut();
         Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> WelcomePage()), (val)=> false);
        }, child: Text("Sign out"))
      ],
    );
  }

}