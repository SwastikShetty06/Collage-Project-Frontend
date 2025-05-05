import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

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
    final fullUrl = 'http://10.0.2.2:8080$safeUrl';

    print('Attempting to open in Chrome: $fullUrl');

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
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        throw 'Could not launch file: $uri';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage =
        fileUrl.toLowerCase().endsWith('.png') ||
        fileUrl.toLowerCase().endsWith('.jpeg') ||
        fileUrl.toLowerCase().endsWith('.jpg');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue, // Updated to blue for consistent theme
      ),
      body: Center(
        child:
            isImage
                ? Image.network(
                  'http://10.0.2.2:8080$fileUrl', // Fixed emulator path
                )
                : const Icon(
                  Icons.picture_as_pdf,
                  size: 100,
                  color: Colors.blue,
                ), // Blue icon for consistency
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadFile,
        child: const Icon(Icons.download),
        backgroundColor: Colors.blue,
        foregroundColor:
            Colors.white, // Floating action button color to match theme
      ),
    );
  }
}
