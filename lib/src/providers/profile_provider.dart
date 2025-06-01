import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/services/auth_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileProvider extends ChangeNotifier{
  final String _currentUID = FirebaseAuth.instance.currentUser!.uid;
  bool _isProfileLoading = false;
  bool _isSavingChanges = false;
  String _bio = '';
  String _userName = '';
  String _emailAddress = '';
  String _gender = '';
  int _selectedDay = 0;
  int _selectedMonth = 0;
  int _selectedYear = 0;
  File? _selectedImage;
  UserModel? _currentUser;
  int _selectedTab = 0;

  String get bio => _bio;
  String get userName => _userName;
  String get emailAddress => _emailAddress;
  String get gender => _gender;
  int get selectedDay => _selectedDay;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  File? get selectedImage => _selectedImage;

  UserModel? get currentUser => _currentUser;
  String get currentUID => _currentUID;
  bool get isProfileLoading => _isProfileLoading;
  bool get isSavingChanges => _isSavingChanges;

  int get selectedTab => _selectedTab;
  ProfileProvider(){
    initUserProfile();
  }

  void initUserProfile() async{
    _isProfileLoading = true;
    notifyListeners();
    _currentUser = await UserService.getUserByID(userID: _currentUID);
    if(currentUser != null){
      _bio = _currentUser!.bio ?? '';
      _userName = currentUser!.userName;
      _emailAddress = currentUser!.email;
      _gender = currentUser!.gender ?? '';
      _selectedDay = currentUser!.dob != null ? currentUser!.dob!.day: 1;
      _selectedMonth =  currentUser!.dob != null ? currentUser!.dob!.month: 1;
      _selectedYear =  currentUser!.dob != null ? currentUser!.dob!.year: 2025;
    }
    _isProfileLoading = false;
    notifyListeners();
  }

  void setBio(String bio){
    _bio = bio;
    notifyListeners();
  }

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
    _gender = gender;
    notifyListeners();
  }



  void onTabChange(int index){
    _selectedTab = index;
    notifyListeners();
  }

  void pickImage() async{
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if(pickedImage != null){
      _selectedImage = File(pickedImage.path);
      notifyListeners();
    }
  }

  void onSaveChangesTap(VoidCallback onChangesDone) async{
    _isSavingChanges = true;
    notifyListeners();
    String? imageUrl;
    if(_selectedImage != null){
      imageUrl = await UserService.uploadImage(_selectedImage!);
    }
    UserModel user = UserModel(
        userID: _currentUID,
        userName: userName,
        email: _emailAddress,
        bio: bio,
        dob: DateTime(_selectedYear, _selectedMonth, _selectedDay),
        gender: _gender,
        profilePicture: imageUrl ?? _currentUser!.profilePicture,
        interests: _currentUser!.interests,
        mood: _currentUser!.mood
    );

    await AuthService.instance.updateUserInfo(updatedMap: user.toMap());
    _currentUser = user;
    _isSavingChanges = false;
    _selectedImage = null;
    notifyListeners();

    onChangesDone();
  }

  void clear() async{
    _currentUser = null;
    _bio = '';
    _emailAddress = '';
    _userName = '';
    _gender = '';
    _selectedDay = 0;
    _selectedMonth = 0;
    _selectedYear = 0;
    _selectedImage = null;
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}