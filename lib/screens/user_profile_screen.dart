import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'document_view_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String viewerId;
  final int profileUserId;

  const UserProfileScreen({
    super.key,
    required this.viewerId,
    required this.profileUserId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  List<dynamic> _documents = [];
  bool _isFollowing = false;
  bool _isLoading = true;
  bool _isActionLoading = false; // For follow/unfollow button spinner

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.fetchProfile(widget.profileUserId);
      final docs = await _authService.fetchUserDocuments(widget.profileUserId);
      final following = await _authService.getFollowedUsers(
        int.parse(widget.viewerId),
      );
      setState(() {
        _user = user;
        _documents = docs;
        _isFollowing = following.any((u) => u['id'] == widget.profileUserId);
      });
    } catch (e) {
      debugPrint('Failed to load profile: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_isActionLoading) return;

    setState(() => _isActionLoading = true);
    final followerId = int.parse(widget.viewerId);

    try {
      if (_isFollowing) {
        await _authService.unfollowUser(followerId, widget.profileUserId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unfollowed')));
      } else {
        await _authService.followUser(followerId, widget.profileUserId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Followed')));
      }
      setState(() => _isFollowing = !_isFollowing);
    } catch (e) {
      debugPrint('Follow/Unfollow error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_user?['fullName']}\'s Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header row
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                  child: Text(
                    (_user?['fullName'] ?? '').isNotEmpty
                        ? _user!['fullName'][0].toUpperCase()
                        : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user?['fullName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(_user?['email'] ?? ''),
                      if (_user?['collegeName'] != null)
                        Text('College: ${_user!['collegeName']}'),
                      if (_user?['universityName'] != null)
                        Text('University: ${_user!['universityName']}'),
                      if (_user?['courseName'] != null)
                        Text('Course: ${_user!['courseName']}'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child:
                      _isActionLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(_isFollowing ? 'Unfollow' : 'Follow'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),

            // Documents section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Uploaded Documents',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _documents.isEmpty
                      ? const Center(child: Text('No documents uploaded yet.'))
                      : ListView.builder(
                        itemCount: _documents.length,
                        itemBuilder: (context, index) {
                          final doc = _documents[index];
                          final url = doc['fileUrl'] as String? ?? '';
                          final isPdf = url.toLowerCase().endsWith('.pdf');
                          return ListTile(
                            title: Text(doc['title'] ?? ''),
                            leading: Icon(
                              isPdf ? Icons.picture_as_pdf : Icons.image,
                              color: Colors.blue,
                            ),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => DocumentViewScreen(
                                          fileUrl: url,
                                          title: doc['title'] ?? '',
                                        ),
                                  ),
                                ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
