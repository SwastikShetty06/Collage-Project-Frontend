import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class FollowingScreen extends StatefulWidget {
  final String userId;

  const FollowingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final AuthService _authService = AuthService();
  List<dynamic> _followedUsers = [];
  bool _isLoading = true;
  String _error = '';
  Set<int> _unfollowingUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadFollowedUsers();
  }

  Future<void> _loadFollowedUsers() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final users = await _authService.getFollowedUsers(
        int.parse(widget.userId),
      );
      setState(() {
        _followedUsers = users;
        _isLoading = false;

        if (_followedUsers.isEmpty) {
          _error =
              'You are not following anyone yet. Start following new people!';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load followed users. Please try again.';
        _isLoading = false;
      });
      print('Error loading followed users: $e');
    }
  }

  Future<void> _unfollowUser(int followedId) async {
    setState(() {
      _unfollowingUserIds.add(followedId);
    });

    try {
      await _authService.unfollowUser(int.parse(widget.userId), followedId);
      await _loadFollowedUsers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to unfollow user: $e')));
    } finally {
      setState(() {
        _unfollowingUserIds.remove(followedId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _followedUsers.isEmpty
              ? Center(
                child: Text(
                  _error,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadFollowedUsers,
                child: ListView.builder(
                  itemCount: _followedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _followedUsers[index];
                    final int followedId = user['id'];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.account_circle, size: 40),
                        title: Text(user['fullName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${user['email']}'),
                            if (user['collegeName'] != null)
                              Text('College: ${user['collegeName']}'),
                            if (user['universityName'] != null)
                              Text('University: ${user['universityName']}'),
                            if (user['courseName'] != null)
                              Text('Course: ${user['courseName']}'),
                          ],
                        ),
                        trailing:
                            _unfollowingUserIds.contains(followedId)
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : IconButton(
                                  icon: const Icon(
                                    Icons.person_remove,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _unfollowUser(followedId),
                                ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
