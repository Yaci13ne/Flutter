import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  File? _croppedFile;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  /// Pick + Crop Image
  Future<void> pickAndCropImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    setState(() => _loading = true);

final cropped = await ImageCropper().cropImage(
  sourcePath: picked.path,
  compressQuality: 95,
  uiSettings: [
    AndroidUiSettings(
      toolbarTitle: "Crop Image",
      toolbarColor: Colors.black,
      toolbarWidgetColor: Colors.white,
      lockAspectRatio: false,
    ),
    IOSUiSettings(
      title: "Crop Image",
    ),
  ],
);
    

    if (cropped != null) {
      setState(() {
        _croppedFile = File(cropped.path);
      });
    }

    setState(() => _loading = false);
  }

  /// Share Cropped Image
  Future<void> shareImage() async {
    if (_croppedFile == null) return;

    final dir = await getTemporaryDirectory();

    final file = File(
      "${dir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    await file.writeAsBytes(
      await _croppedFile!.readAsBytes(),
    );

    await Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Image Tool"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Preview Image
            if (_croppedFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  _croppedFile!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            /// Crop Button
            ElevatedButton.icon(
              onPressed: pickAndCropImage,
              icon: const Icon(Icons.photo),
              label: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Pick & Crop Image"),
            ),

            const SizedBox(height: 12),

            /// Share Button
            if (_croppedFile != null)
              ElevatedButton.icon(
                onPressed: shareImage,
                icon: const Icon(Icons.share),
                label: const Text("Share Image"),
              ),
          ],
        ),
      ),
    );
  }
}
