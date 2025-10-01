import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(
    MaterialApp(
      home: const Game(),
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 53, 97, 173),
        splashColor: const Color.fromARGB(255, 7, 21, 44),
        textTheme: const TextTheme(
          labelMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 40,
            fontStyle: FontStyle.italic,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    ),
  );
}

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  var variableLeft = 1;
  var variableRight = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          'Mini game',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).splashColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(44.0),
        child: Column(
          children: [
            Text(
              variableLeft == variableRight
                  ? 'Wow You won!'
                  : 'Make them similar',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Randomit();
                    },
                    child: Image.asset('images/image-${variableLeft}.png'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Randomit();
                    },
                    child: Image.asset('images/image-${variableRight}.png'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void Randomit() {
    return setState(() {
      variableLeft = Random().nextInt(9) + 1;
      variableRight = Random().nextInt(9) + 1;
    });
  }
}
