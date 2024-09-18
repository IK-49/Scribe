import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:writing_feed_app/login_pages/landing_page.dart';
import 'feed.dart';
import 'profile.dart';
import 'notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isExpanded = false; // Controls the visibility of the overlay box
  String prompt = 'Loading...'; // Placeholder text for the prompt

  static const List<Widget> _pages = <Widget>[
    Feed(),
    ProfilePage(),
    Notifications(),
  ];

  @override
  void initState() {
    super.initState();
    _getDailyPrompt(); // Fetch the prompt when the app starts
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _getDailyPrompt() async {
    final response =
        await http.get(Uri.parse('https://aarikg.pythonanywhere.com/pick'));
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      setState(() {
        prompt = json['todaysPick']; // Replace the placeholder with the actual prompt
      });
    } else {
      setState(() {
        prompt = 'Error fetching prompt';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 107, 99, 255),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Get context within Builder
              },
            );
          },
        ),
        title: Text("Writing Feed"),
      ),
      body: Stack(
        children: [
          // Main screen content (Feed, Profile, Notifications)
          Column(
            children: [
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          ),
          // Positioned overlay button and expanding box
          Positioned(
            top: 10, // Position it below the app bar
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Circular arrow icon button in the center
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 25,
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Expanding box when the arrow is pressed
                if (_isExpanded)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prompt, // Display the fetched prompt here
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Navigation' +
                          "\n\n Current User ID: " +
                          FirebaseAuth.instance.currentUser!.displayName
                              .toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LandingPage()),
                  );
                },
                child: Text("Sign Out"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
