import 'package:flutter/material.dart';

/// Global notifier — import this anywhere you need to read or toggle the theme.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.light,
);
