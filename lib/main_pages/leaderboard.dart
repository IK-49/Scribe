import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  // Stream to get all users ordered by their likesReceived field
  Stream<QuerySnapshot> _usersLeaderboardStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('likesReceived', descending: true) // Order by likes
        .limit(10) // Limit to top 10 users (adjust as needed)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Consistent AppBar with rest of the app
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4.0, // Add drop shadow for consistency
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: Colors.indigoAccent,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.indigoAccent),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersLeaderboardStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading leaderboard.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final String displayName = user['displayName'] ?? 'Anonymous';
              final int likesReceived = user['likesReceived'] ?? 0;

              return ListTile(
                leading: Text(
                  '#${index + 1}', // Rank number
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(displayName),
                trailing: Text(
                  '$likesReceived Likes',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
