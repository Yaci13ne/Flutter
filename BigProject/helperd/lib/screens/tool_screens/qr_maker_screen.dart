import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrMakerScreen extends StatefulWidget {
  const QrMakerScreen({super.key});

  @override
  State<QrMakerScreen> createState() => _QrMakerScreenState();
}

class _QrMakerScreenState extends State<QrMakerScreen> {
  final TextEditingController controller = TextEditingController();

  String qrData = "";
  String error = "";

  bool isValidUrl(String text) {
    final uri = Uri.tryParse(text);
    return uri != null && (uri.hasScheme || text.startsWith("www"));
  }

  void generateQR() {
    final input = controller.text.trim();

    if (input.isEmpty) {
      setState(() {
        error = "Please enter data";
        qrData = "";
      });
      return;
    }

    if (!isValidUrl(input)) {
      setState(() {
        error = "Enter a valid link (https://example.com)";
        qrData = "";
      });
      return;
    }

    setState(() {
      qrData = input;
      error = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Professional QR Generator"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            /// Input Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Enter Website or Image Link",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: "https://example.com",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: generateQR,
                        icon: const Icon(Icons.qr_code),
                        label: const Text("Generate QR"),
                      ),
                    ),
                    if (error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          error,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// QR Display
            if (qrData.isNotEmpty)
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      QrImageView(
                        data: qrData,
                        size: 220,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        qrData,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
