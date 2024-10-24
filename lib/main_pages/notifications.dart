import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? 'null';
    addSampleNotifications(userId); // Add sample notifications when page is initialized
  }

  // Fetch notifications from Firestore
  Stream<QuerySnapshot> _fetchNotifications() {
    if (userId == 'null') {
      return Stream.empty();
    }

    return _firestore
        .collection('notifications')
        .doc(userId)
        .collection('userNotifications')
        .orderBy('read', descending: false) // Sort by unread first
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // Consistent app bar height
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 4.0, // Drop shadow for a modern effect
          title: const Text(
            'Notifications',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final String title = notification['title'] ?? 'No title';
              final String body = notification['body'] ?? 'No details';
              final bool read = notification['read'] ?? false;

              return ListTile(
                leading: Icon(
                  read ? Icons.notifications : Icons.notifications_active,
                  color: read ? Colors.grey : Colors.indigoAccent,
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: read ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(body),
                onTap: () {
                  // Mark the notification as read when tapped
                  notification.reference.update({'read': true});
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> addSampleNotifications(String userId) async {
    List<Map<String, dynamic>> sampleNotifications = [
      {
        'title': 'Welcome to Scribe!',
        'body': 'Hi there! We’re excited to have you on Scribe. Start your writing journey today by posting your first response to the daily prompt.',
        'read': false
      },
      {
        'title': 'Weekly Writing Tips',
        'body': 'This week’s tip: Focus on creating dynamic characters that grow throughout your story. Check out more tips in the Writing Tips section!',
        'read': false
      },
      {
        'title': 'New Prompt Available!',
        'body': 'A new daily prompt is live: "What if animals could talk?". Share your creative ideas and see what others are writing about!',
        'read': false
      },
    ];

    for (var notification in sampleNotifications) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .add(notification);
    }

    print('Specific sample notifications added successfully!');
  }
}
