import 'package:flutter/material.dart';


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
      appBar: AppBar(title: Text('Resume Generator')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _buildTextField(label: "Full Name", onSaved: (val) => name = val!),
            _buildTextField(label: "Email", onSaved: (val) => email = val!),
            _buildTextField(label: "Phone", onSaved: (val) => phone = val!),
            _buildTextField(label: "Summary", onSaved: (val) => summary = val!),
            _buildTextField(label: "Education", onSaved: (val) => education = val!),
            _buildTextField(label: "Experience", onSaved: (val) => experience = val!),
            _buildTextField(label: "Skills", onSaved: (val) => skills = val!),
            _buildTextField(label: "Projects", onSaved: (val) => projects = val!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
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
              },
              child: Text("Generate Resume"),
            )
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required FormFieldSetter<String> onSaved}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        onSaved: onSaved,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        maxLines: label == "Summary" || label == "Projects" ? 3 : 1,
      ),
    );
  }
}
