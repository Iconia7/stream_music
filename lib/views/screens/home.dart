// ignore_for_file: use_super_parameters, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:project/views/screens/dashboard.dart';
import 'package:project/views/screens/library.dart';
import 'package:project/views/screens/profile.dart';
import 'package:project/views/screens/search.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> toggleTheme;

  const HomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(isDarkMode: _isDarkMode),
      SearchScreen(),
      LibraryScreen(),
      ProfileScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.toggleTheme,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the back arrow
        title: const Text(
          "Stream Music App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.black,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDarkMode
                  ? [Colors.grey[900]!, Colors.grey[800]!]
                  : [Colors.lightBlueAccent, Colors.blue],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: widget.isDarkMode ? Colors.grey[850] : Colors.blue,
        selectedItemColor: widget.isDarkMode ? Colors.white : Colors.white,
        unselectedItemColor: widget.isDarkMode
            ? Colors.grey.withOpacity(0.6)
            : const Color.fromARGB(255, 36, 35, 35).withOpacity(0.6),
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
