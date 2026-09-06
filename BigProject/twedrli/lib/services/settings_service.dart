import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:twedrli/theme/theme_modifier.dart';

class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _textScaleKey = 'text_scale';
  static const String _reduceMotionKey = 'reduce_motion';
  static const String _highContrastKey = 'high_contrast';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.light.index;
    themeModeNotifier.value = ThemeMode.values[themeIndex];

    // Load text scale
    textScaleNotifier.value = prefs.getDouble(_textScaleKey) ?? 1.0;

    // Load reduce motion
    reduceMotionNotifier.value = prefs.getBool(_reduceMotionKey) ?? false;

    // Load high contrast
    highContrastNotifier.value = prefs.getBool(_highContrastKey) ?? false;

    // Load search & language
    searchRadiusNotifier.value = prefs.getString('search_radius') ?? '1 km';
    defaultSortNotifier.value = prefs.getString('default_sort') ?? 'Newest First';
    appLanguageNotifier.value = prefs.getString('app_language') ?? 'English';

    // Listen for changes and save
    themeModeNotifier.addListener(() {
      prefs.setInt(_themeKey, themeModeNotifier.value.index);
    });
    textScaleNotifier.addListener(() {
      prefs.setDouble(_textScaleKey, textScaleNotifier.value);
    });
    reduceMotionNotifier.addListener(() {
      prefs.setBool(_reduceMotionKey, reduceMotionNotifier.value);
    });
    highContrastNotifier.addListener(() {
      prefs.setBool(_highContrastKey, highContrastNotifier.value);
    });
    searchRadiusNotifier.addListener(() {
      prefs.setString('search_radius', searchRadiusNotifier.value);
    });
    defaultSortNotifier.addListener(() {
      prefs.setString('default_sort', defaultSortNotifier.value);
    });
    appLanguageNotifier.addListener(() {
      prefs.setString('app_language', appLanguageNotifier.value);
    });
  }
}
