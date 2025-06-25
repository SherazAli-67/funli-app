import 'package:flutter/material.dart';

class SheetCloseIconWidget extends StatelessWidget {
  const SheetCloseIconWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    100))
        ),
        onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.close));
  }
}