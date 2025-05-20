import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class DocumentViewScreen extends StatefulWidget {
  final String fileUrl;
  final String title;

  const DocumentViewScreen({
    super.key,
    required this.fileUrl,
    required this.title,
  });

  @override
  State<DocumentViewScreen> createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  String? localFilePath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (_isPdf(widget.fileUrl)) {
      _downloadAndSaveFileForPDFView();
    } else {
      setState(() => isLoading = false);
    }
  }

  bool _isPdf(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  Future<void> _downloadAndSaveFileForPDFView() async {
    final safeUrl =
        widget.fileUrl.startsWith('/') ? widget.fileUrl : '/${widget.fileUrl}';
    final fullUrl = 'http://10.0.2.2:8080$safeUrl';

    try {
      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp_doc.pdf');
        await file.writeAsBytes(bytes);
        setState(() {
          localFilePath = file.path;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Download error: $e');
      setState(() => isLoading = false);
    }
  }

  void _downloadFile() async {
    final safeUrl =
        widget.fileUrl.startsWith('/') ? widget.fileUrl : '/${widget.fileUrl}';
    final fullUrl = 'http://10.0.2.2:8080$safeUrl';

    print('Launching file in browser: $fullUrl');

    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'action_view',
        data: fullUrl,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        package: 'com.android.chrome',
      );
      await intent.launch();
    } else {
      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch file: $uri';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage =
        widget.fileUrl.toLowerCase().endsWith('.png') ||
        widget.fileUrl.toLowerCase().endsWith('.jpeg') ||
        widget.fileUrl.toLowerCase().endsWith('.jpg');

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.blue),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : isImage
                ? Image.network('http://10.0.2.2:8080${widget.fileUrl}')
                : localFilePath != null
                ? PDFView(
                  filePath: localFilePath!,
                  enableSwipe: true,
                  autoSpacing: true,
                  swipeHorizontal: false,
                  pageFling: true,
                  onError: (error) => print('PDF error: $error'),
                  onPageError:
                      (page, error) => print('Page $page error: $error'),
                )
                : const Text('Failed to load document.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadFile,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.download),
      ),
    );
  }
}
