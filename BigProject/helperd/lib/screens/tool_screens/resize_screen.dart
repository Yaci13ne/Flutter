import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:helpd/utils/constants.dart';
import 'package:helpd/widgets/base_tool_screen.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ResizeScreen extends StatefulWidget {
  const ResizeScreen({super.key});

  @override
  State<ResizeScreen> createState() => _ResizeScreenState();
}

class _ResizeScreenState extends State<ResizeScreen> {
  XFile? _pickedImage;
  Uint8List? _originalBytes;
  Uint8List? _resizedBytes;

  img.Image? _decoded;

  bool _isProcessing = false;
  bool _maintainAspect = true;

  String? _status;
  String? _originalSize;

  final _widthCtrl = TextEditingController(text: "1080");
  final _heightCtrl = TextEditingController(text: "1080");

  Future<void> _pickImage({bool camera = false}) async {
    final picked = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return;

    setState(() {
      _pickedImage = picked;
      _originalBytes = bytes;
      _decoded = decoded;
      _resizedBytes = null;
      _originalSize = "${decoded.width} × ${decoded.height}";
      _widthCtrl.text = decoded.width.toString();
      _heightCtrl.text = decoded.height.toString();
    });
  }

  Future<void> _resizeImage() async {
    if (_decoded == null) return;

    final w = int.tryParse(_widthCtrl.text) ?? 0;
    final h = int.tryParse(_heightCtrl.text) ?? 0;

    if (w <= 0 || h <= 0) {
      setState(() => _status = "Invalid dimensions");
      return;
    }

    setState(() => _isProcessing = true);

    final resized = img.copyResize(
      _decoded!,
      width: w,
      height: h,
      interpolation: img.Interpolation.cubic, // high quality resize
    );

    final jpg = img.encodeJpg(resized, quality: 100); // max quality

    setState(() {
      _resizedBytes = Uint8List.fromList(jpg);
      _status = "Resized to $w × $h";
      _isProcessing = false;
    });
  }

  void _onWidthChanged(String value) {
    if (!_maintainAspect || _decoded == null) return;

    final w = int.tryParse(value);
    if (w == null) return;

    final ratio = _decoded!.height / _decoded!.width;
    _heightCtrl.text = (w * ratio).round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolScreen(
      title: "Resize",
      subtitle: "Custom dimensions",
      icon: Icons.aspect_ratio,
      iconColor: const Color(0xFFF59E0B),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PICK AREA
            _PickArea(
              bytes: _originalBytes,
              color: const Color(0xFFF59E0B),
              onGallery: () => _pickImage(),
              onCamera: () => _pickImage(camera: true),
            ),

            if (_originalSize != null) ...[
              const SizedBox(height: 8),
              Text(
                "Original: $_originalSize",
                style: const TextStyle(color: kTextSecondary, fontSize: 12),
              ),
            ],

            if (_originalBytes != null) ...[
              const SizedBox(height: 20),
              _buildDimensionsCard(),
              const SizedBox(height: 16),
              ActionButton(
                label: "Resize Image",
                icon: Icons.aspect_ratio,
                color: const Color(0xFFF59E0B),
                onTap: _resizeImage,
                isLoading: _isProcessing,
              ),
            ],

            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(
                _status!,
                style: const TextStyle(color: kTextPrimary),
              ),
            ],

            if (_resizedBytes != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  _resizedBytes!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              ActionButton(
                label: "Share",
                icon: Icons.share,
                onTap: () async {
                  final xfile = XFile.fromData(
                    _resizedBytes!,
                    mimeType: "image/jpeg",
                    name: "resized.jpg",
                  );
                  await Share.shareXFiles([xfile]);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionsCard() {
    return Column(
      children: [
        _DimField(
          label: "Width (px)",
          controller: _widthCtrl,
          onChanged: _onWidthChanged,
        ),
        const SizedBox(height: 12),
        _DimField(
          label: "Height (px)",
          controller: _heightCtrl,
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class _PickArea extends StatelessWidget {
  final Uint8List? bytes;
  final Color color;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _PickArea({
    required this.bytes,
    required this.color,
    required this.onGallery,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    if (bytes == null) {
      return GestureDetector(
        onTap: onGallery,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              "Select Image",
              style: TextStyle(color: kTextPrimary),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.memory(
            bytes!,
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onGallery,
                child: const Text("Gallery"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: onCamera,
                child: const Text("Camera"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DimField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(String) onChanged;

  const _DimField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
      ),
    );
  }
}
