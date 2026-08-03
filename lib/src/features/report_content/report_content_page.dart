import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/providers/report_content_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../res/app_textstyles.dart';
import '../../widgets/primary_btn.dart';
import '../../widgets/secondary_btn.dart';

class ReportContentPage extends StatelessWidget{
  const ReportContentPage({super.key, required ReelModel reel}) :_reel = reel ;
  final ReelModel _reel;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportContentProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Notifications", style: AppTextStyles.headingTextStyle3,),
        leading: IconButton(onPressed: ()=> context.pop(), icon: Icon(Icons.arrow_back_ios_new_rounded)),
      ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
        child: Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppColors.reportContentFillColor
              ),
              child: Row(
                spacing: 10,
                children: [
                  Expanded(child: Text(provider.selectedReasonDescription)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(imageUrl: _reel.thumbnailUrl ?? AppIcons.icDefaultThumbnailUrl, height: 75, width: 75, fit: BoxFit.cover,),
                  )
                ],
              ),
            ),
            Text("Select a reason", style: AppTextStyles.buttonTextStyle.copyWith(fontWeight: FontWeight.w700),),
            Expanded(child: ListView.builder(
                itemCount: AppData.reportReasons.length,
                itemBuilder: (ctx, index){
                  String reason = AppData.reportReasons[index]['reason'];
                  String description = AppData.reportReasons[index]['description'];
                  return ListTile(
                    onTap: (){
                      provider.setSelectedReason(reason: reason, description: description);
                    },
                    contentPadding: EdgeInsets.zero,
                    title: Text(reason, style: AppTextStyles.smallTextStyle.copyWith(fontSize: 16),),
                    leading:
                    CircleAvatar(
                      backgroundColor: AppColors.textFieldBorderColor,
                      radius: 8,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.white,
                        child: reason == provider.selectedReason ? CircleAvatar(
                          radius: 5,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.primaryGradient
                            ),
                          ),
                        ) : null,
                      )
                    ),
                  );
                /*  return RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    value: false, groupValue: '', onChanged: (val){}, title: Text(reason, style: AppTextStyles.smallTextStyle.copyWith(fontSize: 16),),);*/
                })),
           provider.isReporting ? LoadingWidget(color: AppColors.primaryColor,) : Row(
              spacing: 20,
              children: [
                Expanded(child: SecondaryBtn(
                    btnText: "Cancel", icon: '', onTap: ()=> Navigator.of(context).pop(), borderRadius: 16)),
                Expanded(child: PrimaryBtn(btnText: "Report",
                  icon: '',
                  onTap: ()async{
                    await provider.onReportContentTap(reelID: _reel.reelID);
                    context.pop();
                  },
                  bgGradient: AppIcons.primaryBgGradient, borderRadius: 16,)),

              ],
            )
          ],
        ),
      )),
    );
  }

}