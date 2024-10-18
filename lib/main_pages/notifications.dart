import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  Stream<List<Map<String, dynamic>>> _fetchNotifications() {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Correct the Firestore path to match your rules (notifications/{userId}/userNotifications)
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('userNotifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
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
