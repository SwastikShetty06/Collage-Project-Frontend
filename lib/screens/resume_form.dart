import 'package:flutter/material.dart';
import 'package:project_frontend/screens/resume_pdf.dart';

class ResumeFormPage extends StatefulWidget {
  @override
  _ResumeFormPageState createState() => _ResumeFormPageState();
}

class _ResumeFormPageState extends State<ResumeFormPage> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String phone = '';
  String summary = '';
  String education = '';
  String experience = '';
  String skills = '';
  String projects = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildCardInput("Full Name", (val) => name = val!),
                    _buildCardInput("Email", (val) => email = val!),
                    _buildCardInput("Phone", (val) => phone = val!),
                    _buildCardInput("Summary", (val) => summary = val!, maxLines: 3),
                    _buildCardInput("Education", (val) => education = val!),
                    _buildCardInput("Experience", (val) => experience = val!),
                    _buildCardInput("Skills", (val) => skills = val!),
                    _buildCardInput("Projects", (val) => projects = val!, maxLines: 3),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          onPressed: _onGenerateResume,
                          child: const Text("Generate Resume"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.badge,
              size: 40,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Resume Builder",
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            "Fill in your details below",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInput(String label, FormFieldSetter<String> onSaved, {int maxLines = 1}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextFormField(
          decoration: InputDecoration.collapsed(hintText: label),
          maxLines: maxLines,
          onSaved: onSaved,
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ),
    );
  }

  void _onGenerateResume() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResumePreviewPage(
            name: name,
            email: email,
            phone: phone,
            summary: summary,
            education: education,
            experience: experience,
            skills: skills,
            projects: projects,
          ),
        ),
      );
    }
  }
}
