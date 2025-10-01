import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Me.dart';
import 'home.dart';
import 'user_model.dart';
import 'UserData.dart';

class UserProvider with ChangeNotifier {
  final User _user = User(name: "user", email: "name@email.vide");


  // Start with default values
  UserData _userData = UserData(
    gender: 'Male',
    weight: 80,
    height: 175,
    activityLevel: 'Highly Active',
    goal: 'Maintain your physique',
    age: 19,
  );

  User get user => _user;
  UserData get userData => _userData;

  void updateName(String newName) {
    _user.name = newName;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    _user.email = newEmail;
    notifyListeners();
  }

  void updateProfileImage(File? newImage) {
    _user.profileImage = newImage;
    notifyListeners();
  }

  void updateUserData(UserData newData) {
    print('Updating user data with: ${newData.weight}kg, ${newData.height}cm');
    _userData = newData;
    _saveUserData();

    notifyListeners();
    _saveUserData();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    print('Saving to prefs: ${_userData.weight}kg');

    await prefs.setInt('weight', _userData.weight);
    await prefs.setInt('height', _userData.height);
    await prefs.setInt('age', _userData.age);
    await prefs.setString('activityLevel', _userData.activityLevel);
    await prefs.setString('goal', _userData.goal);
    await prefs.setString('gender', _userData.gender);
  }

  bool _isUserDataLoaded = false;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedData = UserData(
      gender: prefs.getString('gender') ?? 'Male',
      weight: prefs.getInt('weight') ?? 70,
      height: prefs.getInt('height') ?? 175,
      activityLevel: prefs.getString('activityLevel') ?? 'Not Very Active',
      goal: prefs.getString('goal') ?? 'Maintain your physique',
      age: prefs.getInt('age') ?? 25,
    );

    _userData = loadedData;
    _isUserDataLoaded = true;
    notifyListeners();
  }

  bool get isUserDataLoaded => _isUserDataLoaded;

  Future<void> saveProfileImagePath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString('profileImagePath', path);
    } else {
      await prefs.remove('profileImagePath');
    }
  }

  Future<void> loadProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');
    if (path != null) {
      _user.profileImage = File(path);
      notifyListeners();
    }
  }

  NutritionGoals calculateNutritionGoals() {
    final macros = _userData.calculateMacros();

    return NutritionGoals(
      dailyCalories: macros['calories']?.round() ?? 2468,
      proteinGoal: macros['protein']?.round() ?? 133,
      fatGoal: macros['fat']?.round() ?? 69,
      carbsGoal: macros['carbs']?.round() ?? 333,
      weight :macros['weight']?.round()?? 70,      age :macros['age']?.round()?? 10,
      height :macros['height']?.round()?? 180,

    );
  }



  Details calculateNutritionGoals1() {
    final macros = _userData.calculateMacros();

    return Details(
    
      weight :macros['weight']?.round()?? 70,      age :macros['age']?.round()?? 10,
      height :macros['height']?.round()?? 180,

    );
  }
  // Helper getter for just the weight
  int get currentWeight {
    return calculateNutritionGoals().weight;
  }
}
