import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

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
      final response = await _authService.fetchProfile(
        int.parse(widget.userId),
      );
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

  Color _generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
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
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.only(top: 120, bottom: 120),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: _generateRandomColor(),
                          child: Text(
                            _user?['fullName'][0] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Name & Email
                        Text(
                          'Welcome, ${_user?['fullName'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: ${_user?['email'] ?? ''}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Edit Mode Fields
                        if (_isEditing) ...[
                          if (_message.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                _message,
                                style: TextStyle(
                                  color:
                                      _message.contains('updated') ||
                                              _message.contains('success')
                                          ? Colors.green
                                          : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          _buildTextField(_collegeController, 'College Name'),
                          _buildTextField(
                            _universityController,
                            'University Name',
                          ),
                          _buildTextField(_courseController, 'Course Name'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Update Profile'),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _passwordController,
                            'New Password',
                            obscure: true,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Change Password'),
                          ),
                        ] else ...[
                          // Display Mode
                          Text('College: ${_user?['collegeName'] ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          Text(
                            'University: ${_user?['universityName'] ?? 'N/A'}',
                          ),
                          const SizedBox(height: 8),
                          Text('Course: ${_user?['courseName'] ?? 'N/A'}'),
                        ],

                        const SizedBox(height: 20),
                        // Buttons side by side
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _toggleEditMode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _isEditing ? 'Exit Edit' : 'Edit Profile',
                              ),
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
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.edit),
        ),
      ),
    );
  }
}
