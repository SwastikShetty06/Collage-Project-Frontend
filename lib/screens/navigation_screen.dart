import 'package:flutter/material.dart';
import 'package:project_frontend/screens/following_screen.dart';
import 'profile_screen.dart';
import 'users_screen.dart';
import 'browse_screen.dart';
import 'home_page.dart';

class NavigationScreen extends StatefulWidget {
  final String userId;

  const NavigationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  NavigationScreenState createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomePage(userId: widget.userId),
      BrowseScreen(userId: widget.userId),
      UsersScreen(userId: widget.userId),
      FollowingScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
    ];
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -1),
            ),
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Browse'),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Following',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
