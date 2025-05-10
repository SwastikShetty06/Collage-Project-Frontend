import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final response =
      await _authService.fetchProfile(int.parse(widget.userId));
      setState(() {
        _user = response;
        _collegeController.text = _user?['collegeName'] ?? '';
        _universityController.text = _user?['universityName'] ?? '';
        _courseController.text = _user?['courseName'] ?? '';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to load user data.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _collegeController.text = _user?['collegeName'] ?? '';
        _universityController.text = _user?['universityName'] ?? '';
        _courseController.text = _user?['courseName'] ?? '';
        _passwordController.clear();
      }
    });
  }

  void _changePassword() async {
    if (_passwordController.text.trim().isEmpty) {
      setState(() => _message = 'Please enter a new password');
      return;
    }
    try {
      final response = await _authService.changePassword(
        int.parse(widget.userId),
        _passwordController.text.trim(),
      );
      setState(() {
        _message = response['message'] ?? 'Password changed successfully';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: Failed to change password';
      });
    }
  }

  void _updateProfile() async {
    if (_user == null) return;

    final updatedProfile = {
      'id': int.parse(widget.userId),
      'fullName': _user!['fullName'],
      'email': _user!['email'],
      'collegeName': _collegeController.text.trim(),
      'universityName': _universityController.text.trim(),
      'courseName': _courseController.text.trim(),
    };

    final success = await _authService.updateProfile(updatedProfile);
    setState(() {
      _message = success ? 'Profile updated!' : 'Failed to update profile.';
    });

    if (success) {
      _loadUserData();
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Stack(
            children: [
              Container(
                height: 260,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                  ),
                ),
              ),
              Positioned.fill(
                top: 60,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Text(
                          _user?['fullName'][0] ?? '',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _user?['fullName'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _user?['email'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_isEditing) ...[
                    if (_message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _message,
                          style: TextStyle(
                            color: _message.contains('updated') ||
                                _message.contains('success')
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    _buildTextField(_collegeController, 'College Name'),
                    _buildTextField(
                        _universityController, 'University Name'),
                    _buildTextField(_courseController, 'Course Name'),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: _blueButtonStyle(),
                      child: const Text('Update Profile'),
                    ),
                    _buildTextField(_passwordController, 'New Password',
                        obscure: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _changePassword,
                      style: _blueButtonStyle(),
                      child: const Text('Change Password'),
                    ),
                  ] else ...[
                    _buildInfoCard('Email', _user?['email']),
                    _buildInfoCard('College', _user?['collegeName']),
                    _buildInfoCard('University', _user?['universityName']),
                    _buildInfoCard('Course', _user?['courseName']),
                  ],
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _toggleEditMode,
                        style: _blueButtonStyle(),
                        child: Text(_isEditing ? 'Cancel' : 'Edit'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: const Icon(Icons.edit, color: Colors.blue),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String? value) {
    IconData icon;
    switch (label) {
      case 'Email':
        icon = Icons.email;
        break;
      case 'College':
        icon = Icons.school;
        break;
      case 'University':
        icon = Icons.location_city;
        break;
      case 'Course':
        icon = Icons.book;
        break;
      default:
        icon = Icons.info;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value ?? 'N/A'),
      ),
    );
  }

  ButtonStyle _blueButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
