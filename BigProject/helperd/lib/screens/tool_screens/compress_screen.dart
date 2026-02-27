import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class CompressScreen extends StatelessWidget {
  const CompressScreen({super.key});

  Future<void> compress() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return;

    final compressed = img.encodeJpg(decoded, quality: 60);

    debugPrint("Compressed bytes: ${compressed.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Compress Image")),
      body: Center(
        child: ElevatedButton(
          onPressed: compress,
          child: const Text("Compress"),
        ),
      ),
    );
  }
}
