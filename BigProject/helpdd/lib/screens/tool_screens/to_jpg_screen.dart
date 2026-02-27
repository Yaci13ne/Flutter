import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PictureToJpgScreen extends StatefulWidget {
  const PictureToJpgScreen({super.key});

  @override
  State<PictureToJpgScreen> createState() => _PictureToJpgScreenState();
}

class _PictureToJpgScreenState extends State<PictureToJpgScreen> {
  Uint8List? _originalBytes;
  Uint8List? _jpgBytes;

  bool _loading = false;

  final picker = ImagePicker();

  /// Pick Image
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _originalBytes = bytes;
      _jpgBytes = null;
    });
  }

  /// Convert To JPG
  Future<void> convertToJpg() async {
    if (_originalBytes == null) return;

    setState(() => _loading = true);

    try {
      final decoded = img.decodeImage(_originalBytes!);

      if (decoded == null) return;

      final jpg = img.encodeJpg(decoded, quality: 95);

      setState(() {
        _jpgBytes = Uint8List.fromList(jpg);
      });
    } catch (e) {
      debugPrint("$e");
    }

    setState(() => _loading = false);
  }

  /// Share Image
  Future<void> shareImage() async {
    if (_jpgBytes == null) return;

    final dir = await getTemporaryDirectory();

    final file = await File(
      "${dir.path}/converted.jpg",
    ).writeAsBytes(_jpgBytes!);

    Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Picture → JPG")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Original Preview
            if (_originalBytes != null)
              Image.memory(
                _originalBytes!,
                height: 180,
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: convertToJpg,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Convert To JPG"),
            ),

            const SizedBox(height: 20),

            /// Result Preview
            if (_jpgBytes != null) ...[
              Image.memory(
                _jpgBytes!,
                height: 180,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: shareImage,
                child: const Text("Share JPG"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
