import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ExpandImageScreen extends StatefulWidget {
  const ExpandImageScreen({super.key});

  @override
  State<ExpandImageScreen> createState() => _ExpandImageScreenState();
}

class _ExpandImageScreenState extends State<ExpandImageScreen> {
  XFile? imageFile;
  bool loading = false;

  final picker = ImagePicker();

  /// Pick Image From Inside Screen
  Future<void> pickImage() async {
    setState(() => loading = true);

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = picked;
      });
    }

    setState(() => loading = false);
  }

  /// Double Tap Zoom
  final TransformationController controller = TransformationController();

  void toggleZoom() {
    final zoomed = Matrix4.identity()..scale(2.5);
    final normal = Matrix4.identity();

    setState(() {
      controller.value = controller.value == normal ? zoomed : normal;
    });
  }

  @override
  void initState() {
    super.initState();

    /// Auto open picker when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pickImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Viewer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: pickImage,
          )
        ],
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : imageFile == null
                ? const Text("No Image Selected")
                : GestureDetector(
                    onDoubleTap: toggleZoom,
                    child: InteractiveViewer(
                      transformationController: controller,
                      minScale: 1,
                      maxScale: 5,
                      child: Image.network(
                        imageFile!.path,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
      ),
    );
  }
}
