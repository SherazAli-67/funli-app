import 'package:flutter/material.dart';
import 'package:funli_app/src/features/profile_analytics_dashboard/mood_history.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:go_router/go_router.dart';

import 'analytics_creator_insights_page.dart';

class ProfileAnalyticsDashboard extends StatefulWidget {
  const ProfileAnalyticsDashboard({super.key});

  @override
  State<ProfileAnalyticsDashboard> createState() => _ProfileAnalyticsDashboardState();
}

class _ProfileAnalyticsDashboardState extends State<ProfileAnalyticsDashboard> with SingleTickerProviderStateMixin {
  // int _selectedTabIndex = 0;
  String _selectedTimeRange = 'This month';
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    /*_tabController.addListener(() {
      setState(()=> _selectedTabIndex = _tabController.index);
    });*/
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Dashboard', style: AppTextStyles.headingTextStyle3,),
        leadingWidth: 30,
        centerTitle: false,
        leading: IconButton(onPressed: ()=> context.pop(), icon: Icon(Icons.arrow_back)),
        actions: [
         /* TextButton(
            onPressed: _showTimeRangeDropdown,
            child: Row(
              spacing: 10,
              children: [
                Text(
                  _selectedTimeRange,
                  style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400, color: Colors.black),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),*/
        ],
      ),
      body: SafeArea(
        child: Column(
          spacing: 20,
          children: [
            _buildTabBar(),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  AnalyticsMoodHistory(),
                  AnalyticsCreatorInsightsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showTimeRangeDropdown() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimeRangeOption('This week'),
              _buildTimeRangeOption('This month'),
              _buildTimeRangeOption('This year'),
              _buildTimeRangeOption('All time'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeRangeOption(String option) {
    return ListTile(
      title: Text(option),
      onTap: () {
        setState(() {
          _selectedTimeRange = option;
        });
        Navigator.pop(context);
      },
      trailing: _selectedTimeRange == option ? const Icon(Icons.check, color: Colors.blue) : null,
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor)
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: AppGradients.primaryGradient,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.unSelectedTabColor,
        labelStyle: AppTextStyles.smallTextStyle,
        tabs: [
          Tab(text: 'Mood History'),
          Tab(text: 'Creator Insights'),
        ],
      ),
    );
  }
}