import 'package:flutter/material.dart';
import 'package:xorussian/game.dart';
import 'package:xorussian/main.dart';

// ---------------- START PAGE ----------------
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final blueCtrl = TextEditingController();
  final redCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Players Setup')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: blueCtrl,
              decoration: const InputDecoration(labelText: 'Blue Player'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: redCtrl,
              decoration: const InputDecoration(labelText: 'Red Player'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (blueCtrl.text.isEmpty || redCtrl.text.isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GamePage(
                      blueName: blueCtrl.text,
                      redName: redCtrl.text,
                    ),
                  ),
                );
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
