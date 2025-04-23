import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UploadScreen extends StatefulWidget {
  final String userId;
  const UploadScreen({super.key, required this.userId});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final AuthService _noteService = AuthService();
  File? _file;
  final TextEditingController _titleCtrl = TextEditingController();
  final List<TextEditingController> _keywordCtrls = List.generate(
    3,
    (_) => TextEditingController(),
  );
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() => _file = File(result.files.single.path!));
    }
  }

  Future<void> _upload() async {
    if (_file == null || _titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file and enter a title')),
      );
      return;
    }

    final keywords = _keywordCtrls
        .map((e) => e.text.trim())
        .where((e) => e.isNotEmpty)
        .join(',');

    setState(() => _isUploading = true);

    try {
      await _noteService.upload(
        _file!,
        _titleCtrl.text.trim(),
        keywords,
        widget.userId,
      );

      if (!mounted) return;
      Navigator.pop(context, true); // Go back to browse screen
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text("Pick Document"),
            ),
            if (_file != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected: ${_file!.path.split('/').last}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _keywordCtrls[i],
                  decoration: InputDecoration(labelText: 'Keyword ${i + 1}'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _upload,
              child:
                  _isUploading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
