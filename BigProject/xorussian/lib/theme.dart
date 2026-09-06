import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Colors
  static const Color backgroundStart = Color(0xFF0F2027);
  static const Color backgroundMiddle = Color(0xFF203A43);
  static const Color backgroundEnd = Color(0xFF2C5364);

  static const Color primaryBlue = Color(0xFF00E5FF);
  static const Color primaryRed = Color(0xFFFF1744);
  
  static const Color surfaceColor = Color(0x1AFFFFFF); // 10% white for glass
  static const Color surfaceHighlight = Color(0x33FFFFFF); // 20% white
  static const Color borderColor = Color(0x4DFFFFFF); // 30% white
  static const Color textBody = Color(0xFFE0E0E0);
  
  // Gradients
  static const LinearGradient coreBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundStart, backgroundMiddle, backgroundEnd],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.transparent, // Used with a gradient container wrapper
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: primaryRed,
      surface: surfaceColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textBody),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent, // usually wrapped in ink or gradient
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      hintStyle: const TextStyle(color: Colors.white54),
      labelStyle: const TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
  );
}
