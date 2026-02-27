// TODO Implement this library.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfToWordScreen extends StatefulWidget {
  const PdfToWordScreen({super.key});

  @override
  State<PdfToWordScreen> createState() => _PdfToWordScreenState();
}

class _PdfToWordScreenState extends State<PdfToWordScreen> {
  File? _pdfFile;
  File? _docFile;
  bool _loading = false;

  /// ⭐ Replace with real conversion API
  final String apiKey = "PUT_YOUR_API_KEY";

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf"],
    );

    if (result == null) return;

    setState(() {
      _pdfFile = File(result.files.single.path!);
    });
  }

  Future<void> convertPdfToWord() async {
    if (_pdfFile == null) return;

    setState(() => _loading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://api.cloudconvert.com/convert"),
      );

      request.headers["Authorization"] = "Bearer $apiKey";

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          _pdfFile!.path,
        ),
      );

      request.fields["inputformat"] = "pdf";
      request.fields["outputformat"] = "docx";

      final response = await request.send();

      final bytes = await response.stream.toBytes();

      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/converted.docx",
      );

      await file.writeAsBytes(bytes);

      setState(() {
        _docFile = file;
      });
    } catch (e) {
      debugPrint("$e");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF to Word")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_pdfFile != null)
              Text(
                "Selected: ${_pdfFile!.path.split("/").last}",
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickPdf,
              child: const Text("Pick PDF"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: convertPdfToWord,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Convert to Word"),
            ),
            const SizedBox(height: 20),
            if (_docFile != null)
              ElevatedButton(
                onPressed: () {
                  Share.shareXFiles(
                    [XFile(_docFile!.path)],
                  );
                },
                child: const Text("Share Word File"),
              ),
          ],
        ),
      ),
    );
  }
}
