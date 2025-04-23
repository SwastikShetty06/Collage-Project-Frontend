import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewScreen extends StatelessWidget {
  final String fileUrl;
  final String title;

  const DocumentViewScreen({
    super.key,
    required this.fileUrl,
    required this.title,
  });

  void _downloadFile() async {
    final safeUrl = fileUrl.startsWith('/') ? fileUrl : '/$fileUrl';
    final uri = Uri.parse('http://localhost:8080$safeUrl');

    print('Attempting to open: $uri');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch file: $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage =
        fileUrl.toLowerCase().endsWith('.png') ||
        fileUrl.toLowerCase().endsWith('.jpg');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child:
            isImage
                ? Image.network('http://localhost:8080$fileUrl')
                : const Icon(Icons.picture_as_pdf, size: 100),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadFile,
        child: const Icon(Icons.download),
      ),
    );
  }
}
