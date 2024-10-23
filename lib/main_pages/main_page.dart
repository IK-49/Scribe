import 'package:Scribe/login_pages/landing_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'streak_calendar.dart';
import 'settings.dart';
import 'feed.dart';
import 'profile.dart';
import 'notifications.dart';
import 'writing_tips.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _hasUnreadNotifications = false;

  static List<Widget> _pages = <Widget>[
    const Feed(),
    ProfilePage(),
    Notifications(),
  ];

  @override
  void initState() {
    super.initState();
    checkUnreadNotifications();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 4.0,  // Drop shadow for a modern effect
          title: const Text(
            'Scribe',
            style: TextStyle(
              color: Colors.indigoAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.indigoAccent),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigoAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        iconSize: 28,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none),
                if (_hasUnreadNotifications)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.indigoAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Scribe',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? 'Guest User',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', () {
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.person, 'Profile', () {
              setState(() {
                _selectedIndex = 1;
              });
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.calendar_today, 'Streaks', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StreakCalendar()),
              );
            }),
            _buildDrawerItem(Icons.edit, 'Writing Tips', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WritingTipsPage()),
              );
            }),
            _buildDrawerItem(Icons.settings, 'Settings', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            }),
            _buildDrawerItem(Icons.logout, 'Sign Out', () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LandingPage()),
                  );
                }
              } catch (e) {
                print('Error signing out: $e');
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigoAccent),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
