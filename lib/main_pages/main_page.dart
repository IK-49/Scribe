import 'package:Scribe/main_pages/settings.dart';
import 'package:Scribe/post/new_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Scribe/login_pages/landing_page.dart';
import 'feed.dart';
import 'profile.dart';
import 'notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore to fetch unread notifications
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'writing_tips.dart'; // <-- Add this import for the new page

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _hasUnreadNotifications =
      false; // To track if there are unread notifications
  String prompt = 'Loading...'; // Placeholder text for the prompt
  bool _isExpanded = false; // Controls the visibility of the prompt
  String todaysPrompt = "";
  double _boxHeight = 0.0; // Controls height for animation
  double _opacity = 0.0; // Controls opacity for animation

  static List<Widget> _pages = <Widget>[
    const Feed(),
    ProfilePage(),
    Notifications(),
  ];

  @override
  void initState() {
    super.initState();
    fetchPrompt();
    checkUnreadNotifications(); // Call this to check unread notifications
  }

  Future<void> fetchPrompt() async {
    final response = await http
        .get(Uri.parse('http://izadkhokhar.pythonanywhere.com/promptGenerate'));
    if (response.statusCode == 200) {
      setState(() {
        todaysPrompt = json.decode(response.body)['todaysPrompt'];
      });
    } else {
      throw Exception('Failed to load prompt');
    }
  }

  void _togglePrompt() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _boxHeight = 250.0; // Set the expanded height
        _opacity = 1.0; // Make the content fully visible
      } else {
        _boxHeight = 0.0; // Collapse the height to 0
        _opacity = 0.0; // Make the content invisible
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 2) {
        // If notifications page is selected, mark notifications as read
        markNotificationsAsRead();
      }
    });
  }

  Future<void> checkUnreadNotifications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _hasUnreadNotifications = snapshot.docs.isNotEmpty;
        });
      });
    }
  }

  Future<void> markNotificationsAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final unreadNotifications = await FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .where('read', isEqualTo: false)
          .get();

      for (var doc in unreadNotifications.docs) {
        await doc.reference.update({'read': true});
      }

      setState(() {
        _hasUnreadNotifications = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.blue,
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
        title: const Text(
          "Scribe",
          style: TextStyle(
            fontFamily: "LexendDeca",
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          ),
          // New Post button (now in the bottom-right corner)
          if (_selectedIndex == 0)
            Positioned(
              bottom: 40,
              right: 50,
              child: FloatingActionButton(
                child: Icon(Icons.create),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => NewPost()));
                },
              ),
            ),
          // Show/Hide Today's Prompt button (now in the bottom center)
          if (_selectedIndex == 0)
            Positioned(
              bottom: MediaQuery.of(context).size.height *
                  0.03, // Move it up slightly from the bottom
              left:
                  MediaQuery.of(context).size.width * 0.25, // Adjust alignment
              right: MediaQuery.of(context).size.width * 0.25,
              child: ElevatedButton(
                onPressed: _togglePrompt,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
                child: Text(
                  _isExpanded ? "Hide Today's Prompt" : "Show Today's Prompt",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          // Animated prompt box
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500), // Animation duration
              curve: Curves.easeInOut, // Smooth animation curve
              height: _boxHeight, // The animated height
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500), // Smooth opacity change
                opacity: _opacity, // The animated opacity
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Today's Prompt",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      todaysPrompt,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _togglePrompt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_hasUnreadNotifications)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
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
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Navigation' +
                          "\n\n Current User ID: " +
                          (FirebaseAuth.instance.currentUser != null
                              ? FirebaseAuth.instance.currentUser!.displayName
                                  .toString()
                              : 'Guest'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1; // Set to Feed page index
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Writing Tips'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WritingTipsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LandingPage()),
                  );
                },
                child: const Text("Sign Out"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
