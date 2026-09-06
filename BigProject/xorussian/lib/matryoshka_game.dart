import 'package:flutter/material.dart';
import 'package:xorussian/start_page.dart';
import 'package:xorussian/theme.dart';

class MatryoshkaGame extends StatelessWidget {
  const MatryoshkaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XO Russian',
      theme: AppTheme.darkTheme,
      home: const StartPage(),
    );
  }
}
