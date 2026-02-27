import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrMakerScreen extends StatefulWidget {
  const QrMakerScreen({super.key});

  @override
  State<QrMakerScreen> createState() => _QrMakerScreenState();
}

class _QrMakerScreenState extends State<QrMakerScreen> {
  final controller = TextEditingController();
  String data = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Maker")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Enter QR Data"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => data = controller.text),
              child: const Text("Generate"),
            ),
            const SizedBox(height: 20),
            if (data.isNotEmpty) QrImageView(data: data, size: 200),
          ],
        ),
      ),
    );
  }
}
