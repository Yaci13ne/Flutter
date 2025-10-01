import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BasketManager extends ChangeNotifier {
  // Singleton implementation
  static final BasketManager _instance = BasketManager._internal();
  factory BasketManager() => _instance;
  BasketManager._internal() {
    _loadConfirmedItems();
  }

  final List<Map<String, dynamic>> _foodItems = [];
  final List<Map<String, dynamic>> _confirmedItems = [];

  List<Map<String, dynamic>> get foodItems => List.unmodifiable(_foodItems);
  List<Map<String, dynamic>> get confirmedItems => List.unmodifiable(_confirmedItems);

  // Prevent disposal since this is a long-lived service
  @override
  void dispose() {
    // Don't call super.dispose() to keep the manager alive
    // super.dispose(); 
  }

  void addItem(Map<String, dynamic> item) {
    if (!_foodItems.any((element) => element['name'] == item['name'])) {
      _foodItems.add(item);
      notifyListeners();
    }
  }

  bool isItemAdded(String name) => _foodItems.any((item) => item['name'] == name);

  void removeItem(String name) {
    _foodItems.removeWhere((item) => item['name'] == name);
    notifyListeners();
  }

  void confirmItem(String name) {
    final item = _foodItems.firstWhere(
      (item) => item['name'] == name,
      orElse: () => {},
    );

    if (item.isNotEmpty) {
      removeExpiredItems();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      debugPrint("Confirming Item: ${item['name']}, Timestamp: $timestamp");

      _confirmedItems.add({
        'name': item['name'],
        'image': item['image'],
        'calories': item['calories'],
        'fats': item['fats'],
        'protein': item['protein'],
        'carbs': item['carbs'],
        'timestamp': timestamp,
      });

      _foodItems.removeWhere((item) => item['name'] == name);
      _saveConfirmedItems();
      notifyListeners();
    }
  }

  void removeExpiredItems() {
    final now = DateTime.now();
    debugPrint("Current Time: $now");
    debugPrint("Before Cleanup: $_confirmedItems");

    _confirmedItems.removeWhere((item) {
      final itemTime = item['timestamp'] as int? ?? 0;
      final itemDateTime = DateTime.fromMillisecondsSinceEpoch(itemTime);
      final difference = now.difference(itemDateTime);
      final expired = difference.inHours >= 24;
      
      if (expired) {
        debugPrint("Removing Item: ${item['name']}, Added: $itemDateTime, Now: $now");
      }
      return expired;
    });

    debugPrint("After Cleanup: $_confirmedItems");
    _saveConfirmedItems();
    notifyListeners();
  }

  Future<void> _saveConfirmedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('confirmedItems', jsonEncode(_confirmedItems));
    } catch (e) {
      debugPrint('Error saving confirmed items: $e');
    }
  }

  Future<void> _loadConfirmedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('confirmedItems');
      if (data != null) {
        _confirmedItems.clear();
        List<dynamic> decodedData = jsonDecode(data);
        _confirmedItems.addAll(decodedData.map((item) {
          return {
            'name': item['name'],
            'image': item['image'],
            'calories': item['calories'],
            'fats': item['fats'],
            'protein': item['protein'],
            'carbs': item['carbs'],
            'timestamp': (item['timestamp'] as num).toInt(),
          };
        }));
        removeExpiredItems();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading confirmed items: $e');
    }
  }

  int get totalCalories => _confirmedItems.fold(0, (sum, item) => sum + (item['calories'] as num).toInt());
  int get totalProtein => _confirmedItems.fold(0, (sum, item) => sum + (item['protein'] as num).toInt());
  int get totalCarbs => _confirmedItems.fold(0, (sum, item) => sum + (item['carbs'] as num).toInt());
  int get totalFats => _confirmedItems.fold(0, (sum, item) => sum + (item['fats'] as num).toInt());
}