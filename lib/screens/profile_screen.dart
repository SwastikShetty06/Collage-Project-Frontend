import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;

  // Controllers for text fields
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  bool _isLoading = false;
  String _message = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      _user = userData;
      _collegeController.text = _user?['collegeName'] ?? '';
      _universityController.text = _user?['universityName'] ?? '';
      _courseController.text = _user?['courseName'] ?? '';
    });
  }

  void _changePassword() async {
    if (_user == null || _passwordController.text.trim().isEmpty) {
      setState(() => _message = 'Please enter a new password');
      return;
    }
    try {
      final response = await _authService.changePassword(
        _user!['id'],
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

  void _deleteAccount() async {
    if (_user == null) return;
    final success = await _authService.deleteUser(_user!['id']);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _updateProfile() async {
    if (_user == null) return;
    final updatedProfile = {
      'id': _user!['id'],
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
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Welcome, ${_user!['fullName']}',
                style: const TextStyle(fontSize: 20),
              ),
              Text('Email: ${_user!['email']}'),
              const Divider(height: 40),
              TextField(
                controller: _collegeController,
                decoration: const InputDecoration(
                  labelText: 'College Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _universityController,
                decoration: const InputDecoration(
                  labelText: 'University Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Update Profile'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Change Password'),
              ),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color:
                          _message.contains('updated') ||
                                  _message.contains('success')
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete Account'),
              ),
              TextButton(onPressed: _logout, child: const Text('Logout')),
            ],
          ),
        ),
      ),
    );
  }
}
