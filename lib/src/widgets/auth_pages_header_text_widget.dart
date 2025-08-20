import 'package:flutter/material.dart';
import '../res/spacing_constants.dart';

class AuthPagesHeaderTextWidget extends StatelessWidget {
  const AuthPagesHeaderTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 75,
        left: SpacingConstants.screenHorizontalPadding,
        right: SpacingConstants.screenHorizontalPadding,
        bottom: 45
      ),
      child: Text("FEELz", style: TextStyle(fontSize: 75, fontWeight: FontWeight.w700),)
    );
  }
}