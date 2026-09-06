import 'package:flutter/material.dart';

/// Global notifiers — import these anywhere you need to read or toggle settings.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<double> textScaleNotifier = ValueNotifier(1.0);
final ValueNotifier<bool> reduceMotionNotifier = ValueNotifier(false);
final ValueNotifier<bool> highContrastNotifier = ValueNotifier(false);
final ValueNotifier<String> searchRadiusNotifier = ValueNotifier('1 km');
final ValueNotifier<String> defaultSortNotifier = ValueNotifier('Newest First');
final ValueNotifier<String> appLanguageNotifier = ValueNotifier('English');
