import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ResumePreviewPage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String summary;
  final String education;
  final String experience;
  final String skills;
  final String projects;

  const ResumePreviewPage({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.summary,
    required this.education,
    required this.experience,
    required this.skills,
    required this.projects,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resume Preview')),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: PdfPageFormat.a4,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(name,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  )),
              pw.SizedBox(height: 4),
              pw.Text('Email: $email     Phone: $phone',
                  style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 8),
              pw.Divider(),

              // Summary
              _sectionTitle("Profile Summary"),
              pw.Text(summary, style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 10),

              // Experience
              _sectionTitle("Work History"),
              pw.Text(experience, style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 10),

              // Education
              _sectionTitle("Education"),
              pw.Text(education, style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 10),

              // Projects
              _sectionTitle("Projects"),
              pw.Text(projects, style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 10),

              // Skills
              _sectionTitle("Skills"),
              _bulletList(skills),

              // Footer spacing
              pw.Spacer(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  pw.Widget _bulletList(String items) {
    final lines = items.split(RegExp(r'\n|-')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines
          .map((item) => pw.Bullet(
        text: item,
        style: pw.TextStyle(fontSize: 11),
      ))
          .toList(),
    );
  }
}
