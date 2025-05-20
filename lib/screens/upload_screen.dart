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
  final List<TextEditingController> _keywordCtrls =
  List.generate(3, (_) => TextEditingController());
  bool _isUploading = false;

  /// File selected = true => turns icon green
  bool get _isFileSelected => _file != null;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  Future<void> _upload() async {
    if (_file == null || _titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file and enter a title.'),
          backgroundColor: Colors.red,
        ),
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

      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload successful!')),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 260,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 50,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickFile,
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor:_isFileSelected ? Colors.green : Colors.white,
                          child: Icon(
                            Icons.upload_file,
                            color: _isFileSelected ? Colors.white  : Colors.blue,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload Document',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_file != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Selected: ${_file!.path.split('/').last}',
                style: const TextStyle(fontSize: 14),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: 'Title',
                    icon: Icons.title,
                    controller: _titleCtrl,
                  ),
                  ...List.generate(
                    3,
                        (i) => _buildTextField(
                      label: 'Keyword ${i + 1}',
                      icon: Icons.tag,
                      controller: _keywordCtrls[i],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _upload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Upload', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
