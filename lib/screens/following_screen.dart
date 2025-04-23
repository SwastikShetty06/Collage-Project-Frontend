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
  bool _isLoading = true;
  bool _showFollowing = true;
  String _error = '';
  List<dynamic> _users = [];
  Set<int> _actionUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final int id = int.parse(widget.userId);
      final users =
          _showFollowing
              ? await _authService.getFollowedUsers(id)
              : await _authService.getFollowers(id);

      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;

        if (_users.isEmpty) {
          _error =
              _showFollowing
                  ? 'You are not following anyone yet. Start following new people!'
                  : 'Nobody is following you';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error =
            e.toString().contains("Nobody is following you")
                ? "Nobody is following you"
                : 'Failed to load data. Please try again.';
      });
      print('Error loading users: $e');
    }
  }

  Future<void> _unfollowUser(int otherUserId) async {
    if (!mounted) return;
    setState(() {
      _actionUserIds.add(otherUserId);
    });

    try {
      await _authService.unfollowUser(int.parse(widget.userId), otherUserId);
      await _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to unfollow user: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _actionUserIds.remove(otherUserId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connections')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ToggleButtons(
            isSelected: [_showFollowing, !_showFollowing],
            onPressed: (index) {
              setState(() {
                _showFollowing = index == 0;
              });
              _loadUsers();
            },
            borderRadius: BorderRadius.circular(12),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Following'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Followers'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _users.isEmpty
                    ? Center(
                      child: Text(
                        _error,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          final userId = user['id'];

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
                              leading: const Icon(
                                Icons.account_circle,
                                size: 40,
                              ),
                              title: Text(user['fullName']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${user['email']}'),
                                  if (user['collegeName'] != null)
                                    Text('College: ${user['collegeName']}'),
                                  if (user['universityName'] != null)
                                    Text(
                                      'University: ${user['universityName']}',
                                    ),
                                  if (user['courseName'] != null)
                                    Text('Course: ${user['courseName']}'),
                                ],
                              ),
                              trailing:
                                  _showFollowing
                                      ? (_actionUserIds.contains(userId)
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
                                            onPressed:
                                                () => _unfollowUser(userId),
                                          ))
                                      : null,
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
