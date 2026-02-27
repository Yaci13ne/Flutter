import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToAudioScreen extends StatefulWidget {
  const TextToAudioScreen({super.key});

  @override
  State<TextToAudioScreen> createState() => _TextToAudioScreenState();
}

class _TextToAudioScreenState extends State<TextToAudioScreen> {
  final FlutterTts tts = FlutterTts();
  final controller = TextEditingController();

  Future<void> speak() async {
    await tts.speak(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Text To Audio")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: controller, maxLines: 5),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: speak,
              child: const Text("Play Audio"),
            )
          ],
        ),
      ),
    );
  }
}
