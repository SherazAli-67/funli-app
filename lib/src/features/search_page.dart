import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/secondary_btn.dart';
import '../res/app_colors.dart';
import '../res/app_textstyles.dart';

class SearchPage extends StatefulWidget{
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: Column(
              spacing: 10,
              children: [
                SizedBox(
                  height: 48,
                  child: TextField(
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.searchFillColor,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.transparent)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.transparent)
                        ),
                        hintText: 'Search users, feels, trends, hashtags',
                        hintStyle: AppTextStyles.hintTextStyle,
                        prefixIcon: Icon(Icons.search, color: AppColors.greyTextColor,)
                    ),
                  ),
                ),
                Row(
                  spacing: 5,
                  children: [
                    SizedBox(
                      height: 35,
                      width: 100,
                      child: selectedIndex == 0
                          ?  PrimaryBtn(btnText: "Feels", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient, textStyle: AppTextStyles.bodyTextStyle,)
                          : SecondaryBtn(btnText: "Feels", icon: '', onTap: ()=> _onSelectFilterTypeTap(0), textStyle: AppTextStyles.bodyTextStyle,),
                    ),

                    SizedBox(
                      height: 35,
                      width: 100,
                      child: selectedIndex == 1
                          ?  PrimaryBtn(btnText: "Users", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient, textStyle: AppTextStyles.bodyTextStyle,)
                          : SecondaryBtn(btnText: "Users", icon: '', onTap: ()=> _onSelectFilterTypeTap(1), textStyle: AppTextStyles.bodyTextStyle,),
                    ),

                    SizedBox(
                      height: 35,
                      width: 127,
                      child: selectedIndex == 2
                          ?  PrimaryBtn(btnText: "Hashtags", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient, textStyle: AppTextStyles.bodyTextStyle,)
                          : SecondaryBtn(btnText: "Hashtags", icon: '', onTap: ()=> _onSelectFilterTypeTap(2), textStyle: AppTextStyles.bodyTextStyle,),
                    ),
                  ],
                )
              ],
            ),
          ),
          if(selectedIndex == 0)
            Expanded(child: _buildFeelsSearchWidget()),

          if(selectedIndex == 1)
            Expanded(child: _buildUsersSearchWidget()),

          if(selectedIndex == 2)
            Expanded(child: _buildHashtagSearchWidget())
        ],
      )),
    );
  }

  void _onSelectFilterTypeTap(int index) {
    setState(()=> selectedIndex = index);
  }

  Widget _buildUsersSearchWidget() {
    return Center(child: Text("Users search widget"),);
  }

  Widget _buildFeelsSearchWidget() {
    return Center(child: Text("Feels search widget"),);
  }

  Widget _buildHashtagSearchWidget() {
    return Center(child: Text("Hashtag search widget"),);
  }
}