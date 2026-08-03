import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/widgets/user_profile_widget.dart';

class Homepage extends StatelessWidget{
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(16),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          UserProfileWidget(),
          // Expanded(child: Carous)
        ],
      ),
    );
  }
}