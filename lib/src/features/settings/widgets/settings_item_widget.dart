import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../res/app_colors.dart';
import '../../../res/app_textstyles.dart';

class SettingsItemWidget extends StatelessWidget {
  const SettingsItemWidget({
    super.key,
    required String title,
    String? icon,
    VoidCallback? onTap,
    bool isSwitch = false,
    bool isLogout = false,
    Function(bool value)? onSwitchChange,
    bool switchValue = false,
  }): _icon = icon, _title = title, _onTap = onTap,  _isSwitch = isSwitch, _isLogout = isLogout, _onSwitchChange = onSwitchChange, _switchValue = switchValue;
  final String? _icon;
  final String _title;
  final bool _isSwitch;
  final VoidCallback? _onTap;
  final bool _isLogout;
  final Function(bool value)? _onSwitchChange;
  final bool _switchValue;
  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 5),
        onTap: _onTap,
        leading: _icon != null ? SvgPicture.asset(_icon,) : null,
        title: Text(_title, style: _isLogout ? AppTextStyles.buttonTextStyle.copyWith(color: AppColors.logoutRedColor) : AppTextStyles.buttonTextStyle,),
        trailing: _isSwitch ?  CupertinoSwitch(
            inactiveTrackColor:  AppColors.switchTrackColor,
            activeTrackColor: AppColors.purpleColor,
            value: _switchValue, onChanged: _onSwitchChange) : !_isLogout ? Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(Icons.navigate_next_outlined),
        ) : null
    );
  }
}