import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4.0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.indigoAccent,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.indigoAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsItem(
              icon: Icons.notifications,
              title: 'Notification Settings',
              onTap: () {
                // Navigate to Notification Settings
              },
            ),
            _buildSettingsItem(
              icon: Icons.lock,
              title: 'Privacy Settings',
              onTap: () {
                // Navigate to Privacy Settings
              },
            ),
            _buildSettingsItem(
              icon: Icons.person,
              title: 'Account Settings',
              onTap: () {
                // Navigate to Account Settings
              },
            ),
            const Divider(),
            _buildSettingsItem(
              icon: Icons.logout,
              title: 'Sign Out',
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigoAccent),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
