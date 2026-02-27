import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class WordToPdfScreen extends StatefulWidget {
  const WordToPdfScreen({super.key});

  @override
  State<WordToPdfScreen> createState() => _WordToPdfScreenState();
}

class _WordToPdfScreenState extends State<WordToPdfScreen> {
  File? _wordFile;
  File? _pdfFile;

  bool _loading = false;

  /// ⭐ Get API Key From CloudConvert
  final String apiKey = "PUT_YOUR_API_KEY";

  /// Pick Word File
  Future<void> pickWordFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["docx"],
    );

    if (result == null) return;

    setState(() {
      _wordFile = File(result.files.single.path!);
    });
  }

  /// Convert Word → PDF
  Future<void> convertWordToPdf() async {
    if (_wordFile == null) return;

    setState(() => _loading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://api.cloudconvert.com/v2/jobs"),
      );

      request.headers["Authorization"] = "Bearer $apiKey";

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          _wordFile!.path,
        ),
      );

      final response = await request.send();
      final bytes = await response.stream.toBytes();

      final dir = await getTemporaryDirectory();

      final file = File("${dir.path}/converted.pdf");
      await file.writeAsBytes(bytes);

      setState(() {
        _pdfFile = file;
      });
    } catch (e) {
      debugPrint("$e");
    }

    setState(() => _loading = false);
  }

  /// Share PDF
  Future<void> sharePdf() async {
    if (_pdfFile == null) return;

    Share.shareXFiles([XFile(_pdfFile!.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Word → PDF")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_wordFile != null)
              Text(
                "Selected: ${_wordFile!.path.split("/").last}",
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickWordFile,
              child: const Text("Pick Word File"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: convertWordToPdf,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Convert to PDF"),
            ),
            const SizedBox(height: 20),
            if (_pdfFile != null)
              ElevatedButton(
                onPressed: sharePdf,
                child: const Text("Share PDF"),
              ),
          ],
        ),
      ),
    );
  }
}
