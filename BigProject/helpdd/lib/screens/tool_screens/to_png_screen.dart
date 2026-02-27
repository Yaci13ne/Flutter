import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PictureToPngScreen extends StatefulWidget {
  const PictureToPngScreen({super.key});

  @override
  State<PictureToPngScreen> createState() => _PictureToPngScreenState();
}

class _PictureToPngScreenState extends State<PictureToPngScreen> {
  Uint8List? _originalBytes;
  Uint8List? _pngBytes;

  bool _loading = false;

  final picker = ImagePicker();

  /// Pick Image
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _originalBytes = bytes;
      _pngBytes = null;
    });
  }

  /// Convert To PNG
  Future<void> convertToPng() async {
    if (_originalBytes == null) return;

    setState(() => _loading = true);

    try {
      final decoded = img.decodeImage(_originalBytes!);
      if (decoded == null) return;

      final png = img.encodePng(decoded);

      setState(() {
        _pngBytes = Uint8List.fromList(png);
      });
    } catch (e) {
      debugPrint("$e");
    }

    setState(() => _loading = false);
  }

  /// Share PNG
  Future<void> sharePng() async {
    if (_pngBytes == null) return;

    final dir = await getTemporaryDirectory();

    final file = await File(
      "${dir.path}/converted.png",
    ).writeAsBytes(_pngBytes!);

    Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Picture → PNG")),
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
              onPressed: convertToPng,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Convert To PNG"),
            ),

            const SizedBox(height: 20),

            /// PNG Preview
            if (_pngBytes != null) ...[
              Image.memory(
                _pngBytes!,
                height: 180,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: sharePng,
                child: const Text("Share PNG"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
