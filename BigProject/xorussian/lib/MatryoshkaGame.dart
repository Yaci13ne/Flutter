import 'package:flutter/material.dart';
import 'package:xorussian/Startpage.dart';

class MatryoshkaGame extends StatelessWidget {
  const MatryoshkaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XO Russian',
      home: const StartPage(),
    );
  }
}
