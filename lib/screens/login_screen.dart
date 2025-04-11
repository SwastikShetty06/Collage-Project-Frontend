import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result != null) {
      final profile = await _authService.fetchProfile(result['id']);
      if (profile != null && mounted) {
        Navigator.pushReplacementNamed(context, '/profile', arguments: profile);
      }
    } else {
      setState(() => _error = 'Login failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 28, // Increase font size
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 6, 90, 159), // Welcome text color
                ),
              ),
              const SizedBox(height: 16),
              if (_error.isNotEmpty)
                Text(_error, style: const TextStyle(color: Colors.red)),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                          'Login',
                          style: TextStyle(
                            color: Color.fromARGB(255, 6, 90, 159),
                          ),
                        ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "Don't have an account? Register here.",
                  style: TextStyle(color: Color.fromARGB(255, 6, 90, 159)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
