import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = ''; // Reset the error message
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final result = await _authService.login(email, password);

    setState(() => _isLoading = false);

    if (result != null && result['error'] == null) {
      final profile = await _authService.fetchProfile(result['id']);
      if (profile != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => NavigationScreen(userId: result['id'].toString()),
          ),
        );
      } else {
        setState(() {
          _error = 'Failed to load profile. Please try again.';
        });
      }
    } else {
      // Handle the case where there was an error returned from the server
      setState(() {
        _error =
            result?['error'] ??
            'Login failed. Please check your credentials and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'), // Set the AppBar color to blue
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Blue text for the welcome message
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Show error message if there is any
                    if (_error.isNotEmpty)
                      Text(_error, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.blue,
                        ), // Set the icon color to blue
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.blue,
                        ), // Set the icon color to blue
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Set the button color to blue
                        foregroundColor:
                            Colors.white, // Set the button text color to white
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              )
                              : const Text('Login'),
                    ),
                    const SizedBox(height: 12),
                    // New button for Forgot Password
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ), // Blue text for forgot password
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Don't have an account? Register here.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ), // Blue text for register
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
