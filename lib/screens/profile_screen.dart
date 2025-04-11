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
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      _user = userData;
    });
  }

  void _changePassword() async {
    if (_user == null) return;
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final success = await _authService.changePassword(
      _user!['id'],
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _message = success ? 'Password updated!' : 'Failed to update password.';
    });
  }

  void _deleteAccount() async {
    if (_user == null) return;

    final success = await _authService.deleteUser(_user!['id']);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
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
        child: Column(
          children: [
            Text(
              'Welcome, ${_user!['fullName']}',
              style: const TextStyle(fontSize: 20),
            ),
            Text('Email: ${_user!['email']}'),
            const Divider(height: 40),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Change Password'),
            ),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(
                  color:
                      _message.contains('updated') ? Colors.green : Colors.red,
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
    );
  }
}
