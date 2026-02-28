// main.dart
import 'package:flutter/material.dart';
import 'package:twedrli/fabtab.dart';
import 'package:twedrli/theme/theme_modifier.dart';

void main() {
  runApp(const TwedrliApp());
}

class TwedrliApp extends StatelessWidget {
  const TwedrliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Twedrli',
          debugShowCheckedModeBanner: false,

          // ─── Light Theme ──────────────────────────────────────────
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF29B6F6),
              brightness: Brightness.light,
            ),
            fontFamily: 'SF Pro Display',
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF4F6F8),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E1E1E),
            ),
          ),

          // ─── Dark Theme ───────────────────────────────────────────
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF29B6F6),
              brightness: Brightness.dark,
            ),
            fontFamily: 'SF Pro Display',
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
          ),

          themeMode: themeMode,
          home: const FabTabs(),
        );
      },
    );
  }
}

// ─── Shared Colors ────────────────────────────────────────────────────────────
const kBlue = Color(0xFF1E9BF0);
const kBlueDark = Color(0xFF1578C2);
const kBlueBg = Color(0xFFE8F4FD);
const kGrey = Color(0xFF8A9BB0);
const kInputBg = Color(0xFFF5F8FB);
const kBorder = Color(0xFFDDE4ED);
