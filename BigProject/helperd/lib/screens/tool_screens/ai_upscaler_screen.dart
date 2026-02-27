import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';

class AiUpscalerScreen extends StatefulWidget {
  const AiUpscalerScreen({super.key});

  @override
  State<AiUpscalerScreen> createState() => _AiUpscalerScreenState();
}

class _AiUpscalerScreenState extends State<AiUpscalerScreen> {
  Uint8List? originalBytes;
  Uint8List? processedBytes;

  bool loading = false;

  final picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      originalBytes = bytes;
      processedBytes = null;
    });
  }

  /// Fake AI Upscale (Sharp + Resize)
  void upscale() {
    if (originalBytes == null) return;

    setState(() => loading = true);

    final decoded = img.decodeImage(originalBytes!);

    if (decoded == null) return;

    /// Upscale + sharpen simulation
    final resized = img.copyResize(
      decoded,
      width: decoded.width * 2,
      height: decoded.height * 2,
    );

    final sharpened = img.adjustColor(
      resized,
      contrast: 1.2,
    );

    final encoded = img.encodeJpg(sharpened, quality: 95);

    setState(() {
      processedBytes = Uint8List.fromList(encoded);
      loading = false;
    });
  }

  Future<void> shareImage() async {
    if (processedBytes == null) return;

    final file = XFile.fromData(
      processedBytes!,
      mimeType: "image/jpeg",
      name: "upscaled.jpg",
    );

    await Share.shareXFiles([file]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Upscaler Tool")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (originalBytes != null)
              Image.memory(originalBytes!, height: 180),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: upscale,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("AI Upscale"),
            ),
            const SizedBox(height: 20),
            if (processedBytes != null) ...[
              Image.memory(processedBytes!, height: 180),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: shareImage,
                child: const Text("Share Result"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
