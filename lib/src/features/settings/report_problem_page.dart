import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/helpers/snackbar_messages_helper.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/services/settings_service.dart';
import 'package:funli_app/src/widgets/primary_gradient_btn.dart';
import 'package:go_router/go_router.dart';

import '../../res/app_icons.dart';
import '../../res/app_textstyles.dart';

class ReportProblemPage extends StatefulWidget {
  const ReportProblemPage({super.key});

  @override
  ReportProblemPageState createState() => ReportProblemPageState();
}

class ReportProblemPageState extends State<ReportProblemPage> {
  final List<String> topics = ['UX Problems', 'Bug', 'Feature Request', 'Other'];
  String selectedTopic = 'UX Problems';
  final TextEditingController _feedbackController = TextEditingController();

  bool _sendingReport = false;
  // bool _reportSent = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(onPressed: ()=> context.pop(), icon: SvgPicture.asset(AppIcons.icArrowBack)),
        title: Text("Report a Problem", style: AppTextStyles.headingTextStyle3,),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: SizedBox(
            height: size.height*0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Topic Dropdown
                Text("Topic", style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedTopic,
                    underline: SizedBox(),
                    items: topics.map((topic) {
                      return DropdownMenuItem<String>(
                        value: topic,
                        child: Text(topic),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTopic = value!;
                      });
                    },
                  ),
                ),

                SizedBox(height: 30),

                // Feedback TextField
                Text("Your feedback", style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _feedbackController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "Enter your feedback here...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),

               const Spacer(),

                // Gradient Button
                PrimaryGradientBtn(btnText: "Report Problem", icon: '', onTap: _onReportProblemTap, borderRadius: 16, isLoading: _sendingReport,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onReportProblemTap() async {
    String problemDescription = _feedbackController.text.trim();
    setState(()=> _sendingReport = true);
    try{
      await SettingsService.reportProblem(topic: selectedTopic, description: problemDescription);
      SnackbarMessagesHelper.showSnackBarMessage(context: context, title: "Thank you for your feedback.", message: "We’ve received your report and will review it as soon as possible. Your input helps us improve ${AppConstants.appTitle} for everyone.");
      context.pop();
    }catch(e){
      debugPrint("Error while reporting problem: ${e.toString()}");
    }
    _sendingReport = false;

    setState((){});
  }
}
