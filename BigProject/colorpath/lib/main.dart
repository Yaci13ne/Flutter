// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/game_state.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const ColorPathGame());
}

class ColorPathGame extends StatelessWidget {
  const ColorPathGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'Color Path Maze',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D0D1A),
          useMaterial3: true,
        ),
        home: const GameScreen(),
      ),
    );
  }
}
