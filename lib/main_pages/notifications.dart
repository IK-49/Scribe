import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  Stream<List<Map<String, dynamic>>> _fetchNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Query using the UID, filtering out notifications created by the user themselves
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('userNotifications')
        .where('createdBy', isNotEqualTo: userId) // Prevent showing self-created notifications
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  void _markNotificationsAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final unreadNotifications = await FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadNotifications.docs) {
        doc.reference.update({'isRead': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong!"));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications available."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              // Handle the createdAt field safely
              final createdAt = notification['createdAt'] != null
                  ? (notification['createdAt'] as Timestamp).toDate()
                  : DateTime.now(); // Fallback to current time if missing

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigoAccent.withOpacity(0.8),
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    notification['message'] ?? 'No message',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    createdAt.toString(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
