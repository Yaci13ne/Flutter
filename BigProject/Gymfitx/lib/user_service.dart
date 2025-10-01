class UserService {
  static final UserService _instance = UserService._internal();
  
  factory UserService() => _instance;
  
  UserService._internal();
  
  String? _userName;
  
  String get userName => _userName ?? 'User';
  
  void setUserName(String name) {
    _userName = name;
  }
}