import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../util/emoticons.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.fetchProfile(int.parse(widget.userId));
      setState(() {
        _userName = user?['fullName'] ?? 'User';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userName = 'User';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Greeting text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi $_userName!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formattedDate,
                                style: TextStyle(color: Colors.blue[100]),
                              ),
                            ],
                          ),
                          // Notification icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Search',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Question
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'How do you feel about studying?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.more_horiz, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 25),
                      // Emoticons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Column(
                            children: [
                              Emoticons(emoticon: '😭'),
                              SizedBox(height: 8),
                              Text(
                                'Bad',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Emoticons(emoticon: '🥱'),
                              SizedBox(height: 8),
                              Text(
                                'Boring',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Emoticons(emoticon: '😴'),
                              SizedBox(height: 8),
                              Text(
                                'Sleepy',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Emoticons(emoticon: '😁'),
                              SizedBox(height: 8),
                              Text(
                                'Enthusiastic',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
