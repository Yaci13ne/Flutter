import 'package:flutter/material.dart';

enum TileColor {
  red,
  blue,
  green,
  yellow,
  orange,
  purple,
  cyan,
}

extension TileColorExtension on TileColor {
  Color get color {
    switch (this) {
      case TileColor.red:    return const Color(0xFFFF4B4B);
      case TileColor.blue:   return const Color(0xFF4BACFF);
      case TileColor.green:  return const Color(0xFF4BFF6B);
      case TileColor.yellow: return const Color(0xFFFFD14B);
      case TileColor.orange: return const Color(0xFFFF8B4B);
      case TileColor.purple: return const Color(0xFFB84BFF);
      case TileColor.cyan:   return const Color(0xFF4BFFE8);
    }
  }

  String get label {
    switch (this) {
      case TileColor.red:    return 'Red';
      case TileColor.blue:   return 'Blue';
      case TileColor.green:  return 'Green';
      case TileColor.yellow: return 'Yellow';
      case TileColor.orange: return 'Orange';
      case TileColor.purple: return 'Purple';
      case TileColor.cyan:   return 'Cyan';
    }
  }
}
