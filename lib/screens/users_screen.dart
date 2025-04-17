import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  List<dynamic> _profiles = [];
  List<dynamic> _filteredProfiles = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

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
    _fetchProfiles();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fetch all profiles from the backend
  void _fetchProfiles() async {
    final profiles = await _authService.getAllProfiles();
    setState(() {
      _profiles = profiles;
      _filteredProfiles = profiles;
      _isLoading = false;
      _fadeController.forward();
    });
  }

  // Handle search functionality
  void _searchProfiles(String query) {
    setState(() {
      _filteredProfiles =
          _profiles.where((profile) {
            return (profile['fullName'] != null &&
                    profile['fullName'].contains(query)) ||
                (profile['email'] != null &&
                    profile['email'].contains(query)) ||
                (profile['universityName'] != null &&
                    profile['universityName'].contains(query)) ||
                (profile['collegeName'] != null &&
                    profile['collegeName'].contains(query)) ||
                (profile['courseName'] != null &&
                    profile['courseName'].contains(query));
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profiles')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Users',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _searchProfiles,
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      itemCount: _filteredProfiles.length,
                      itemBuilder: (context, index) {
                        final profile = _filteredProfiles[index];
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
                            title: Text(profile['fullName']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${profile['email']}'),
                                Text('College: ${profile['collegeName']}'),
                                Text(
                                  'University: ${profile['universityName']}',
                                ),
                                Text('Course: ${profile['courseName']}'),
                              ],
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
