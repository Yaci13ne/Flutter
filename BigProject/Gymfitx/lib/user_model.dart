// user_model.dart
import 'dart:io';

class User {
  String name;
  String email;
  File? profileImage;

  User({
    required this.name,
    required this.email,
    this.profileImage,
  });
}


