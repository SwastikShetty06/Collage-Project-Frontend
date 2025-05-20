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
  bool _isActionLoading = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Unfollowed')));
      } else {
        await _authService.followUser(followerId, widget.profileUserId);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Followed')));
      }
      setState(() => _isFollowing = !_isFollowing);
    } catch (e) {
      debugPrint('Follow/Unfollow error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
      backgroundColor: const Color(0xFFFDF8FF),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(50),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Centered profile info
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Text(
                          (_user?['fullName'] ?? '').isNotEmpty
                              ? _user!['fullName'][0].toUpperCase()
                              : '',
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _user?['fullName'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _user?['email'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing ? Colors.red : Colors.white,
                          foregroundColor: _isFollowing ? Colors.white : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: _isActionLoading
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue,
                          ),
                        )
                            : Text(_isFollowing ? 'Unfollow' : 'Follow'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),


          // Profile Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_user?['collegeName'] != null)
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('College: ${_user!['collegeName']}'),
                    ],
                  ),
                if (_user?['universityName'] != null)
                  Row(
                    children: [
                      const Icon(Icons.location_city, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('University: ${_user!['universityName']}'),
                    ],
                  ),
                if (_user?['courseName'] != null)
                  Row(
                    children: [
                      const Icon(Icons.book, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('Course: ${_user!['courseName']}'),
                    ],
                  ),
              ],
            ),
          ),

          const Divider(),

          // Documents
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Uploaded Documents',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _documents.isEmpty
                ? const Center(child: Text('No documents uploaded yet.'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final doc = _documents[index];
                final url = doc['fileUrl'] as String? ?? '';
                final isPdf = url.toLowerCase().endsWith('.pdf');
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    title: Text(doc['title'] ?? ''),
                    leading: Icon(
                      isPdf ? Icons.picture_as_pdf : Icons.image,
                      color: Colors.blue,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentViewScreen(
                            fileUrl: url,
                            title: doc['title'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
