import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:xorussian/matryoshka_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase not configured. Please run flutterfire configure. Error: $e');
  }
  runApp(const MatryoshkaGame());
}

enum DollSize { xs, s, m, l, xl }
