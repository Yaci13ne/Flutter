import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _specialTilesEnabled = false;
  bool _wallModeEnabled = true;
  int _gridSize = 8;

  bool get soundEnabled => _soundEnabled;
  bool get specialTilesEnabled => _specialTilesEnabled;
  bool get wallModeEnabled => _wallModeEnabled;
  int get gridSize => _gridSize;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound') ?? true;
    _specialTilesEnabled = prefs.getBool('specialTiles') ?? false;
    _wallModeEnabled = prefs.getBool('wallMode') ?? true;
    _gridSize = prefs.getInt('gridSize') ?? 8;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool v) async {
    _soundEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', v);
    notifyListeners();
  }

  Future<void> setSpecialTilesEnabled(bool v) async {
    _specialTilesEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('specialTiles', v);
    notifyListeners();
  }

  Future<void> setWallModeEnabled(bool v) async {
    _wallModeEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wallMode', v);
    notifyListeners();
  }

  Future<void> setGridSize(int v) async {
    _gridSize = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gridSize', v);
    notifyListeners();
  }
}
