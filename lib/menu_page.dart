import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'language_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isDarkMode = true; // מצב כהה כברירת מחדל

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Center(
                child: Text(
                  'Menu Options',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('My Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                _shareApp();
              },
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Language'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LanguagePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode), // סימן מצב
              title: Text('Mode: ${isDarkMode ? "Black" : "White"}'),
              onTap: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome to the Menu!'),
      ),
    );
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality will be implemented here.')),
    );
  }
}
