import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TranscribeScreen extends StatefulWidget {
  const TranscribeScreen({super.key});

  @override
  State<TranscribeScreen> createState() => _TranscribeScreenState();
}

class _TranscribeScreenState extends State<TranscribeScreen> {
  final SpeechToText stt = SpeechToText();
  String text = "";
  bool listening = false;

  Future<void> toggle() async {
    if (!listening) {
      await stt.initialize();
      stt.listen(onResult: (r) {
        setState(() => text = r.recognizedWords);
      });
    } else {
      stt.stop();
    }

    setState(() => listening = !listening);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transcribe")),
      floatingActionButton: FloatingActionButton(
        onPressed: toggle,
        child: Icon(listening ? Icons.stop : Icons.mic),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(text),
      ),
    );
  }
}
