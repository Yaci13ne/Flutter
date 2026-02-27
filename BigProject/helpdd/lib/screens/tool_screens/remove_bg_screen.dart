import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class RemoveBgScreen extends StatefulWidget {
  const RemoveBgScreen({super.key});

  @override
  State<RemoveBgScreen> createState() => _RemoveBgScreenState();
}

class _RemoveBgScreenState extends State<RemoveBgScreen> {
  Uint8List? _resultImage;
  bool _loading = false;
  bool _saving = false;

  final picker = ImagePicker();

  /// ⭐ Replace with your remove.bg API key
  final String apiKey = "GqTteyiFgkoXo6HXPwBLauTY";

  Future<void> removeBackground() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _loading = true);

    final bytes = await picked.readAsBytes();

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("https://api.remove.bg/v1.0/removebg"),
    );

    request.headers["X-Api-Key"] = apiKey;

    request.files.add(
      http.MultipartFile.fromBytes(
        "image_file",
        bytes,
        filename: "image.jpg",
      ),
    );

    request.fields["size"] = "auto";

    final response = await request.send();

    if (response.statusCode == 200) {
      final result = await response.stream.toBytes();

      setState(() {
        _resultImage = result;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Background removed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _loading = false);
  }

  Future<void> _saveImage() async {
    if (_resultImage == null) return;

    setState(() => _saving = true);

    try {
      // Request storage permission
      if (await _requestPermission(Permission.storage)) {
        // For Android 13+, we need different permission handling
        if (await _requestPermission(Permission.photos)) {
          final result = await ImageGallerySaver.saveImage(
            _resultImage!,
            quality: 100,
            name: "removed_bg_${DateTime.now().millisecondsSinceEpoch}.png",
          );

          if (result['isSuccess']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image saved to gallery!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            throw Exception('Failed to save image');
          }
        } else {
          throw Exception('Photos permission denied');
        }
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      final result = await permission.request();
      return result.isGranted;
    }
  }

  void _resetImage() {
    setState(() {
      _resultImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remove Background"),
        actions: [
          if (_resultImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetImage,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_resultImage != null) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _resultImage!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Image info
                Text(
                  'Size: ${_resultImage!.length ~/ 1024} KB',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _saveImage,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_saving ? 'Saving...' : 'Save to Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : removeBackground,
                      icon: const Icon(Icons.refresh),
                      label: const Text('New Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                if (_loading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text('Removing background...'),
                ] else ...[
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No image selected',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: removeBackground,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Pick Image & Remove Background"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
