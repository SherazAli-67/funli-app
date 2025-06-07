import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/notifications_service.dart';

class NotificationPage extends StatelessWidget{
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new_rounded)),
              Text("Notifications", style: AppTextStyles.headingTextStyle3,),
              FutureBuilder(future: NotificationsService.getUnreadNotifications(), builder: (ctx, snapshot){
                if(snapshot.hasData && snapshot.requireData > 0){
                  return CircleAvatar(
                    backgroundColor: AppColors.redColor,
                    child: Center(child: Text(
                      '${snapshot.requireData}', style: AppTextStyles
                        .smallTextStyle.copyWith(fontWeight: FontWeight.w700,
                        color: Colors.white),),),
                  );
                }

                return SizedBox();
              })
            ],
          )
        ],
      ),
    );
  }

}