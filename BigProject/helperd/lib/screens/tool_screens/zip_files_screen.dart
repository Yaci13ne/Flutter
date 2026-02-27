import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ZipFilesScreen extends StatefulWidget {
  const ZipFilesScreen({super.key});

  @override
  State<ZipFilesScreen> createState() => _ZipFilesScreenState();
}

class _ZipFilesScreenState extends State<ZipFilesScreen> {
  List<PlatformFile> _selectedFiles = [];
  File? _zipFile;
  List<String> _extractedFiles = [];

  bool _loading = false;

  /// Pick Multiple Files
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result == null) return;

    setState(() {
      _selectedFiles = result.files;
    });
  }

  /// Create ZIP File
  Future<void> createZip() async {
    if (_selectedFiles.isEmpty) return;

    setState(() => _loading = true);

    try {
      final archive = Archive();

      for (var file in _selectedFiles) {
        final bytes = await File(file.path!).readAsBytes();

        archive.addFile(
          ArchiveFile(
            file.name,
            bytes.length,
            bytes,
          ),
        );
      }

      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);

      final dir = await getTemporaryDirectory();
      final zipFile = File(
        "${dir.path}/files.zip",
      );

      await zipFile.writeAsBytes(zipBytes!);

      setState(() {
        _zipFile = zipFile;
      });
    } catch (e) {
      debugPrint("$e");
    }

    setState(() => _loading = false);
  }

  /// Share ZIP
  Future<void> shareZip() async {
    if (_zipFile == null) return;

    Share.shareXFiles([XFile(_zipFile!.path)]);
  }

  /// Extract ZIP
  Future<void> extractZip() async {
    if (_zipFile == null) return;

    setState(() => _loading = true);

    try {
      final bytes = await _zipFile!.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final dir = await getTemporaryDirectory();

      List<String> files = [];

      for (var file in archive) {
        final outFile = File("${dir.path}/${file.name}");

        await outFile.writeAsBytes(file.content);

        files.add(outFile.path);
      }

      setState(() {
        _extractedFiles = files;
      });
    } catch (e) {
      debugPrint("$e");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ZIP Files Tool")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFiles,
              child: const Text("Pick Files"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: createZip,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Create ZIP"),
            ),

            const SizedBox(height: 12),

            if (_zipFile != null) ...[
              ElevatedButton(
                onPressed: shareZip,
                child: const Text("Share ZIP"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: extractZip,
                child: const Text("Extract ZIP"),
              ),
            ],

            const SizedBox(height: 20),

            /// Extracted Files List
            Expanded(
              child: ListView.builder(
                itemCount: _extractedFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(
                      _extractedFiles[index].split("/").last,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
