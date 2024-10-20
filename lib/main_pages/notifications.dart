import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  Stream<List<Map<String, dynamic>>> _fetchNotifications() {
    // Use the correct Firebase Auth UID
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print("User ID: $userId"); // Debug to ensure you're getting the correct UID

    // Query using the UID
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId) // Use the UID to access their specific notifications
        .collection('userNotifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  void _markNotificationsAsRead() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
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
          print('Fetched notification: ${notifications}');

          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications."));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              // Handle the createdAt field safely
              final createdAt = notification['createdAt'] != null
                  ? (notification['createdAt'] as Timestamp).toDate()
                  : DateTime.now(); // Fallback to current time if missing

              return ListTile(
                title: Text(notification['message'] ?? 'No message'),
                subtitle: Text(createdAt.toString()),
              );
            },
          );
        },
      ),
    );
  }
}
