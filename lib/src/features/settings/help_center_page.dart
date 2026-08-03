import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/gradient_icon.dart';
import 'package:funli_app/src/widgets/gradient_text_widget.dart';
import 'package:go_router/go_router.dart';
import '../../res/app_gradients.dart';

class HelpCenterPage extends StatefulWidget{
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> with TickerProviderStateMixin{
  late TabController _tabController;

  int _selectedTabIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener((){
      _selectedTabIndex = _tabController.index;
      setState(() {});
    });
    debugPrint("Selected tab: ${_tabController.index}");
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(onPressed: ()=> context.pop(), icon: SvgPicture.asset(AppIcons.icArrowBack)),
        title: Text("Help Center", style: AppTextStyles.headingTextStyle3,),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorWeight: 4.0,
            labelPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0, bottom: 0),

            indicatorSize: TabBarIndicatorSize.tab,
            indicator: ShapeDecoration(
              shape: UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              gradient: AppGradients.primaryGradient,
            ),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Container(
                height: 50,
                alignment: Alignment.center,
                color: Colors.white,
                child: _buildTab(title: 'FAQ', isSelected: _selectedTabIndex == 0),
              ),
              Container(
                height: 50,
                alignment: Alignment.center,
                color: Colors.white,
                child:  _buildTab(title: 'Contact Us', isSelected: _selectedTabIndex == 1),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
                controller: _tabController,
                children: [
                  FAQPage(),
                  ContactUs()
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildTab({required String title, required bool isSelected,}){
    return isSelected ? GradientTextWidget(
      gradient: AppGradients.primaryGradient,
      text: title,
      textStyle: AppTextStyles.buttonTextStyle,
    )
        : Text(title, style: AppTextStyles.buttonTextStyle.copyWith(
        color: AppColors.commentTextColor));
  }
}

class FAQPage extends StatelessWidget{
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AppData.faqs.map((faq){

        bool isExpanded = false;
        return StatefulBuilder(
          builder: (ctx, setState){
            return  Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ExpansionTile(
                  shape: Border(),

                  onExpansionChanged: (val)=> setState(()=> isExpanded = val),
                  title: Text(faq['question'], style: AppTextStyles.tileTitleTextStyle,),
                  trailing: GradientIcon(icon: isExpanded ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 20, gradient: AppGradients.primaryGradient),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(faq['answer'], style: AppTextStyles.smallTextStyle,),
                    )
                  ],

                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class ContactUs extends StatelessWidget{
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AppData.contactUs.map((contact){
        return Card(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(10),
            leading: SvgPicture.asset(contact['icon']),
            title: Text(contact['title'], style: AppTextStyles.buttonTextStyle,),
          ),
        );
      }).toList(),
    );
  }
}
