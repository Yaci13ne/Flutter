import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  Color selectedColor = Colors.blue;
  Uint8List? _imageBytes;
  ui.Image? _uiImage;
  List<Color> _extractedColors = [];
  bool _eyedropperMode = false;

  // Knife position (tip of the knife icon)
  Offset _knifePosition = const Offset(60, 60);
  Color? _sampledColor;
  final GlobalKey _imageKey = GlobalKey();

  void changeColor(Color color) {
    setState(() => selectedColor = color);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    setState(() {
      _imageBytes = bytes;
      _uiImage = frame.image;
      _extractedColors = [];
      _eyedropperMode = false;
      _sampledColor = null;
    });

    await _extractColors(frame.image);
  }

  Future<void> _extractColors(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return;

    final width = image.width;
    final height = image.height;
    final Map<Color, int> colorCount = {};

    const sampleStep = 10;
    for (int y = 0; y < height; y += sampleStep) {
      for (int x = 0; x < width; x += sampleStep) {
        final idx = (y * width + x) * 4;
        final r = byteData.getUint8(idx);
        final g = byteData.getUint8(idx + 1);
        final b = byteData.getUint8(idx + 2);
        final qr = (r ~/ 32) * 32;
        final qg = (g ~/ 32) * 32;
        final qb = (b ~/ 32) * 32;
        final color = Color.fromRGBO(qr, qg, qb, 1.0);
        colorCount[color] = (colorCount[color] ?? 0) + 1;
      }
    }

    final sorted = colorCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _extractedColors = sorted.take(20).map((e) => e.key).toList();
    });
  }

  Future<void> _sampleColorAtKnifeTip() async {
    if (_uiImage == null) return;
    final renderBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // _knifePosition is global; convert to local image widget space
// _knifePosition is global; convert to local image widget space
// "Liar knife": sample 3cm (~85px) ABOVE the actual knife tip position
    const double liarOffsetPx = -90.0;
    final localPos = renderBox.globalToLocal(
      Offset(_knifePosition.dx, _knifePosition.dy - liarOffsetPx),
    );    final widgetSize = renderBox.size;

    final imgW = _uiImage!.width;
    final imgH = _uiImage!.height;

    final scaleX = widgetSize.width / imgW;
    final scaleY = widgetSize.height / imgH;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final renderedW = imgW * scale;
    final renderedH = imgH * scale;
    final offsetX = (widgetSize.width - renderedW) / 2;
    final offsetY = (widgetSize.height - renderedH) / 2;

    final imgX = ((localPos.dx - offsetX) / scale).round().clamp(0, imgW - 1);
    final imgY = ((localPos.dy - offsetY) / scale).round().clamp(0, imgH - 1);

    final byteData =
        await _uiImage!.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return;

    final idx = (imgY * imgW + imgX) * 4;
    final color = Color.fromARGB(
      byteData.getUint8(idx + 3),
      byteData.getUint8(idx),
      byteData.getUint8(idx + 1),
      byteData.getUint8(idx + 2),
    );

    setState(() {
      _sampledColor = color;
      selectedColor = color;
    });
  }

  String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Color Picker Tool"),
        actions: [
          if (_imageBytes != null)
            Tooltip(
              message: _eyedropperMode ? 'Exit Eyedropper' : 'Eyedropper Knife',
              child: IconButton(
                icon: Icon(
                  Icons.colorize,
                  color: _eyedropperMode ? Colors.amber : null,
                ),
                onPressed: () {
                  setState(() {
                    _eyedropperMode = !_eyedropperMode;
                    _sampledColor = null;
                  });
                },
              ),
            ),
          IconButton(
            tooltip: 'Pick Image',
            icon: const Icon(Icons.image),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Image Area ──────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: _imageBytes == null
                ? Container(
                    width: double.infinity,
                    color: selectedColor,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Preview Color",
                            style: TextStyle(
                              fontSize: 22,
                              color: selectedColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text("Pick Image"),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      // Full image
                      Positioned.fill(
                        child: Image.memory(
                          _imageBytes!,
                          key: _imageKey,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),

                      // ── Color info box (fixed top-left, not draggable) ──
                      if (_eyedropperMode)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: _sampledColor ?? Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _sampledColor != null
                                      ? _colorToHex(_sampledColor!)
                                      : 'Drag knife',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // ── Draggable knife icon only ──
                      if (_eyedropperMode)
                        Positioned(
                          left: _knifePosition.dx - 16,
                          top: _knifePosition.dy - 16,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              final screenSize = MediaQuery.of(context).size;
                              setState(() {
                                _knifePosition = Offset(
                                  (_knifePosition.dx + details.delta.dx)
                                      .clamp(0, screenSize.width),
                                  (_knifePosition.dy + details.delta.dy)
                                      .clamp(0, screenSize.height),
                                );
                              });
                              _sampleColorAtKnifeTip();
                            },
                            child: const Icon(
                              Icons.colorize,
                              size: 32,
                              color: Colors.amber,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                )
                              ],
                            ),
                          ),
                        ),

                      // Hint banner
                      if (_eyedropperMode)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Drag the knife icon to sample colors',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),

          // ── Extracted Palette ───────────────────────────────────────
          if (_extractedColors.isNotEmpty)
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _extractedColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final c = _extractedColors[i];
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = c),
                    child: Tooltip(
                      message: _colorToHex(c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == c
                                ? Colors.white
                                : Colors.black26,
                            width: selectedColor == c ? 2.5 : 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 1))
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // ── Selected color bar ──────────────────────────────────────
          Container(
            color: selectedColor,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selected: ${_colorToHex(selectedColor)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── Color Picker ────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: changeColor,
                    enableAlpha: true,
                    displayThumbColor: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
