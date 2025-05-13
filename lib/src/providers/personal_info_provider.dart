import 'package:flutter/material.dart';

class PersonalInfoProvider extends ChangeNotifier{
  String _userName = '';
  String _selectedGender = '';
  final List<String> _selectedInterests = [];
  int  _selectedDay = 0;
  int _selectedMonth = 0;
  int _selectedYear = 0;

  PersonalInfoProvider(){
    DateTime now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _selectedDay = now.day;
    notifyListeners();
  }

  String get userName => _userName;
  String get selectedGender => _selectedGender;
  int get selectedDay => _selectedDay;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  List<String> get selectedInterests => _selectedInterests;

  void setUserName(String userName){
    _userName = userName;
    notifyListeners();
  }
  void setDay(int day){
    _selectedDay = day;
    notifyListeners();
  }

  void setMonth(int month){
    _selectedMonth = month;
    notifyListeners();
  }

  void setYear(int year){
    _selectedYear = year;
    notifyListeners();
  }

  void setGender(String gender){
    _selectedGender = gender;
    notifyListeners();
  }

  void addToInterest(String interest){
    if(_selectedInterests.contains(interest)){
      _selectedInterests.remove(interest);
    }else{
      _selectedInterests.add(interest);
    }
    notifyListeners();
  }

}