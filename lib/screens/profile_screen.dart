import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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

  void _deleteAccount() async {
    if (_user == null) return;
    final success = await _authService.deleteUser(int.parse(widget.userId));
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/');
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
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${_user?['fullName'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Email: ${_user?['email'] ?? ''}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Profile edit area
                      TextField(
                        controller: _collegeController,
                        decoration: const InputDecoration(
                          labelText: 'College Name',
                          prefixIcon: Icon(Icons.school),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _universityController,
                        decoration: const InputDecoration(
                          labelText: 'University Name',
                          prefixIcon: Icon(Icons.account_balance),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _courseController,
                        decoration: const InputDecoration(
                          labelText: 'Course Name',
                          prefixIcon: Icon(Icons.book),
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
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                )
                                : const Text('Change Password'),
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child:
                            _message.isNotEmpty
                                ? Text(
                                  _message,
                                  key: ValueKey(_message),
                                  style: TextStyle(
                                    color:
                                        _message.contains('updated') ||
                                                _message.contains('success')
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete Account'),
                      ),
                      TextButton(
                        onPressed: _logout,
                        child: const Text(
                          'Logout',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
