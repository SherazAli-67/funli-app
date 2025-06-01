import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/widgets/gradient_text_widget.dart';
import '../res/app_colors.dart';
import '../res/app_textstyles.dart';

class SelectDOBWidget extends StatefulWidget{
  const SelectDOBWidget(
      {super.key, required int selectedDay, required int selectedMonth, required int selectedYear, required Function(int day) onDayChange, required Function(int month) onMonthChange, required Function(int year) onYearChange, bool isEdit = false})
      : _selectedDay = selectedDay,
        _selectedMonth = selectedMonth,
        _selectedYear = selectedYear,
        _onDayChange = onDayChange,
        _onMonthChange = onMonthChange,
        _onYearChange = onYearChange,
  _isEdit = isEdit
  ;
  final int _selectedDay;
  final int _selectedMonth;
  final int _selectedYear;
  final Function(int day) _onDayChange;
  final Function(int month) _onMonthChange;
  final Function(int year) _onYearChange;

  final bool _isEdit;

  @override
  State<SelectDOBWidget> createState() => _SelectDOBWidgetState();
}

class _SelectDOBWidgetState extends State<SelectDOBWidget> {
  final months = List<String>.generate(12, (i) => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][i]);
  final days = List<int>.generate(31, (i) => i + 1);
  final years = List<int>.generate(101, (i) => 1925 + i);



  double itemExtent = 60;

  Widget buildPicker<T>({
    required List<T> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    TextStyle selectedTextStyle = TextStyle(
      fontSize:32,
      fontWeight: FontWeight.w700,
    );

    TextStyle unSelectedTextStyle = TextStyle(
      fontSize:  24,
      fontWeight: FontWeight.w400,
      color:  AppColors.lightBlackColor,
    );
    return SizedBox(
      width: 100,
      height: itemExtent * 3,
      child: Stack(
        children: [
          buildListWheelScrollView(onSelectedItemChanged, selectedIndex, items, selectedTextStyle, unSelectedTextStyle),
          // Top Divider
          Positioned(
            top: itemExtent,
            left: 10,
            right: 10,
            child: Divider(thickness: 1),
          ),
          // Bottom Divider
          Positioned(
            top: itemExtent * 2,
            left: 10,
            right: 10,
            child: Divider(thickness: 1),
          ),
        ],
      ),
    );
  }

  ListWheelScrollView buildListWheelScrollView(ValueChanged<int> onSelectedItemChanged, int selectedIndex, List<dynamic> items, TextStyle selectedTextStyle, TextStyle unSelectedTextStyle) {
    return ListWheelScrollView.useDelegate(
          itemExtent: itemExtent,
          perspective: 0.005,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: onSelectedItemChanged,
          controller: FixedExtentScrollController(initialItem: selectedIndex),
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: items.length,
            builder: (context, index) {
              final isSelected = index == selectedIndex;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8), // 8 top + 8 bottom = 16 total
                  child: isSelected ? GradientTextWidget(gradient: AppGradients.primaryGradient, text: items[index].toString(), textStyle: selectedTextStyle,) : Text(
                    items[index].toString(),
                    style: unSelectedTextStyle,
                  ),
                ),
              );
            },
          ),
        );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Text("How old are you?", style: AppTextStyles.subHeadingTextStyle.copyWith(fontWeight: FontWeight.w400),),
           Expanded(child:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildPicker<String>(
                items: months,
                selectedIndex: widget._selectedMonth,
                onSelectedItemChanged: widget._onMonthChange,
              ),
              buildPicker<int>(
                items: days,
                selectedIndex: widget._selectedDay,
                onSelectedItemChanged: widget._onDayChange,
              ),
              buildPicker<int>(
                items: years,
                selectedIndex: widget._selectedYear,
                onSelectedItemChanged: widget._onYearChange,
              ),
            ],
          ),)
        ]);
  }
}