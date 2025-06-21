import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../res/app_icons.dart';
import '../../res/app_textstyles.dart';

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(onPressed: ()=> context.pop(), icon: SvgPicture.asset(AppIcons.icArrowBack)),
        title: Text("Terms & Privacy", style: AppTextStyles.headingTextStyle3,),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            _sectionItem("1. Acceptance of Terms", "By using the FUNLI app, you agree to these Terms and Conditions. If you do not agree, please do not use the app."),
            _sectionItem("2. User Responsibility", "You must be at least 13 years old. You are responsible for your uploaded content. Avoid harmful, offensive, or copyrighted material."),
            _sectionItem("3. Content Ownership", "You retain ownership of your videos but grant FUNLI a license to display them within the app."),
            _sectionItem("4. Community Guidelines", "Respect others. No hate speech, bullying, or harassment. Violations may result in suspension."),
            _sectionItem("5. Account Termination", "We may suspend or terminate your account for violating terms without prior notice."),
            _sectionItem("6. Modifications", "We may update these terms. Continued use of the app means you accept changes."),

            _sectionTitle("Privacy Policy"),
            _sectionItem("1. Information We Collect", "We collect your name, email, profile photo, reels you watch, and device information."),
            _sectionItem("2. How We Use Your Data", "We use your data to personalize your experience, show relevant content, and improve app performance."),
            _sectionItem("3. Data Sharing", "We do not sell your data. We may share it with trusted services (e.g., Firebase) for functionality."),
            _sectionItem("4. Data Security", "We use encryption and secure servers to protect your data."),
            _sectionItem("5. Your Choices", "You can edit/delete your profile or request data deletion by contacting support."),
            _sectionItem("6. Contact", "For questions, email us at: support@funli.app"),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subHeadingTextStyle,
    );
  }

  Widget _sectionItem(String heading, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        spacing: 24,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: AppTextStyles.subHeadingTextStyle,
          ),
          Text(
            description,
            style: AppTextStyles.commentTextStyle
          ),
        ],
      ),
    );
  }
}