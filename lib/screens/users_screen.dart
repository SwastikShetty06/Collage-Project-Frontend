import 'dart:io';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UsersScreen extends StatefulWidget {
  final String userId;
  const UsersScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with SingleTickerProviderStateMixin {
  late final int loggedInUserId;
  final AuthService _authService = AuthService();
  List<dynamic> _profiles = [];
  List<dynamic> _filteredProfiles = [];
  List<int> followedUserIds = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    loggedInUserId = int.parse(widget.userId);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fetchProfiles();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfiles() async {
    // show loader immediately
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final profiles = await _authService.getAllProfiles();
      final followed = await _authService.getFollowedUsers(loggedInUserId);

      if (!mounted) return;
      setState(() {
        _profiles = profiles;
        _filteredProfiles = profiles;
        followedUserIds = followed.map<int>((u) => u['id'] as int).toList();
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  void _searchProfiles(String query) {
    setState(() {
      _filteredProfiles = _profiles.where((p) {
        return (p['fullName']?.contains(query) ?? false) ||
            (p['email']?.contains(query) ?? false) ||
            (p['universityName']?.contains(query) ?? false) ||
            (p['collegeName']?.contains(query) ?? false) ||
            (p['courseName']?.contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _toggleFollow(int profileId) async {
    try {
      if (followedUserIds.contains(profileId)) {
        await _authService.unfollowUser(loggedInUserId, profileId);
        if (!mounted) return;
        setState(() => followedUserIds.remove(profileId));
      } else {
        await _authService.followUser(loggedInUserId, profileId);
        if (!mounted) return;
        setState(() => followedUserIds.add(profileId));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profiles'),
        backgroundColor: Colors.blue, // AppBar color set to blue
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Users',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search, color: Colors.blue), // Blue icon for search
              ),
              onChanged: _searchProfiles,
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    itemCount: _filteredProfiles.length,
                    itemBuilder: (ctx, i) {
                      final p = _filteredProfiles[i];
                      final isFollowing = followedUserIds.contains(p['id']);
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: ListTile(
                          leading: const Icon(Icons.account_circle, size: 40, color: Colors.blue), // Blue icon
                          title: Text(p['fullName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${p['email']}'),
                              Text('College: ${p['collegeName']}'),
                              Text('University: ${p['universityName']}'),
                              Text('Course: ${p['courseName']}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _toggleFollow(p['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing ? Colors.red : Colors.blue, // Blue for follow, Red for unfollow
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
