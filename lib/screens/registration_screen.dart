import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  void _register() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    // Note: Ensure you are sending the correct field name "fullName" instead of "name"
    final result = await _authService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result != null) {
      // Once registration is successful, navigate to the login screen.
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() => _error = 'Registration failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sing Up',
                style: TextStyle(
                  fontSize: 28, // Increase font size
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 6, 90, 159), // Welcome text color
                ),
              ),
              if (_error.isNotEmpty)
                Text(_error, style: const TextStyle(color: Colors.red)),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                          'Register',
                          style: TextStyle(
                            color: Color.fromARGB(255, 6, 90, 159),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
