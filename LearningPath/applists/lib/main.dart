import 'dart:math';

import 'package:applists/Cardit.dart';
import 'package:applists/speak.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Speech()));
}

class Speech extends StatefulWidget {
  const Speech({super.key});

  @override
  State<Speech> createState() => _SpeechState();
}

class _SpeechState extends State<Speech> {
  List<speak> quotes = [
    speak(
      author: 'Winston Churchill',
      quote:
          '"Success is not final, failure is not fatal: it is the courage to continue that counts."',
    ),
    speak(
      author: 'Albert Einstein',
      quote: 'In the middle of every difficulty lies opportunity.',
    ),
    speak(
      author: 'Theodore Roosevelt',
      quote: 'Do what you can, with what you have, where you are',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: quotes
            .map(
              (e) => Cardit(
                quote: e.quote,
                author: e.author,
                delete: () {
                  setState(() {
                    quotes.remove(e);
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
