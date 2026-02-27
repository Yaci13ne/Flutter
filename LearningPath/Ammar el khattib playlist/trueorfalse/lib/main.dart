import 'package:flutter/material.dart';
import 'package:trueorfalse/box.dart';

void main() {
  runApp(MaterialApp(home: Game()));
}

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  List<Box> listit = [
    Box(
      sentence: 'هل يمكن للانسان العيش دون لحوم ',
      path: 'images/image1.png',
      answer: 0,
    ),
    Box(sentence: 'صوت الاسد يسمى زئير', path: 'images/image2.png', answer: 1),
    Box(
      sentence: 'تسمى قارة اسيا بالسيدة العجوز',
      path: 'images/image3.png',
      answer: 0,
    ),
  ];

  List<Padding> thumb = [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(Icons.thumb_up, color: Colors.green),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        Icons.thumb_down,
        color: const Color.fromARGB(255, 243, 38, 2),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(children: thumb),

          Image(image: AssetImage('assets/picture1.jpg')),

          Expanded(
            child: TextButton(
              onPressed: () {
                setState(() {
                  thumb.add(
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.thumb_up, color: Colors.green),
                    ),
                  );
                });
              },
              child: Text("True"),
            ),
          ),
          Expanded(
            child: TextButton(  onPressed: () {
                setState(() {
                  thumb.add(
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.thumb_down, color: const Color.fromARGB(255, 255, 0, 0)),
                    ),
                  );
                });
              }, child: Text("False")),
          ),
        ],
      ),
    );
  }
}
