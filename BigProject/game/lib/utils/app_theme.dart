import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceElevated = Color(0xFF1A1A28);
  static const Color border = Color(0xFF2A2A3A);

  // Player colors
  static const Color player1Color = Color(0xFF4FC3F7); // Blue
  static const Color player2Color = Color(0xFFFF80AB); // Pink

  // Neon accents
  static const Color neonBlue = Color(0xFF00E5FF);
  static const Color neonPink = Color(0xFFFF1493);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonPurple = Color(0xFFBF5FFF);
  static const Color neonOrange = Color(0xFFFF6600);

  // Tile colors (6 distinct game colors)
  static const List<Color> tileColors = [
    Color(0xFF4FC3F7), // cyan-blue
    Color(0xFFFF80AB), // pink
    Color(0xFF69FF47), // green
    Color(0xFFFFD740), // amber
    Color(0xFFB388FF), // purple
    Color(0xFFFF6E40), // deep orange
  ];

  static const List<String> tileColorNames = [
    'Cyan', 'Rose', 'Lime', 'Amber', 'Violet', 'Ember'
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: neonBlue,
        secondary: neonPink,
        surface: surface,
        background: background,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        ThemeData.dark().textTheme,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonBlue,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Game color index constants
class TileColor {
  static const int cyan = 0;
  static const int pink = 1;
  static const int green = 2;
  static const int amber = 3;
  static const int purple = 4;
  static const int orange = 5;
  static const int count = 6;
}
