import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResumePreviewPage extends StatelessWidget {
  final String name,
      email,
      phone,
      summary,
      education,
      experience,
      skills,
      projects;

  ResumePreviewPage({
    required this.name,
    required this.email,
    required this.phone,
    required this.summary,
    required this.education,
    required this.experience,
    required this.skills,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resume Preview')),
      body: PdfPreview(build: (format) => _generatePdf(format)),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                name,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('$email | $phone', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 16),
              pw.Text(
                "Profile Summary",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(summary),
              pw.SizedBox(height: 10),
              pw.Text(
                "Education",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(education),
              pw.SizedBox(height: 10),
              pw.Text(
                "Experience",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(experience),
              pw.SizedBox(height: 10),
              pw.Text(
                "Projects",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(projects),
              pw.SizedBox(height: 10),
              pw.Text(
                "Skills",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(skills),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
