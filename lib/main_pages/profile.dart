import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  int totalPosts = 0;
  int likesReceived = 0;

  @override
  void initState() {
    super.initState();
    fetchUserStats();
  }

  Future<void> fetchUserStats() async {
    if (user != null) {
      QuerySnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: user!.uid)
          .get();

      setState(() {
        totalPosts = postSnapshot.docs.length;

        if (postSnapshot.docs.isNotEmpty) {
          likesReceived = postSnapshot.docs
              .map((doc) => doc['likes'] ?? 0)
              .reduce((a, b) => a + b);
        } else {
          likesReceived = 0;
        }
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchPostArchive() async {
    QuerySnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: user!.uid)
        .orderBy('promptDate', descending: true)
        .get();

    return postSnapshot.docs
        .map((doc) => {
              'prompt': doc['prompt'],
              'content': doc['content'],
              'date': doc['promptDate'].toDate(),
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Information
            Row(
              children: [
                user?.photoURL != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(user!.photoURL!),
                        radius: 40,
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.person, size: 40),
                        radius: 40,
                      ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Anonymous',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(user?.email ?? 'No email',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Post Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Posts', totalPosts),
                _buildStatCard('Likes Received', likesReceived),
              ],
            ),

            const SizedBox(height: 20),

            // Post Archive
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchPostArchive(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No posts in the archive.'));
                  }

                  List<Map<String, dynamic>> posts = snapshot.data!;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 3,
                        child: ListTile(
                          title: Text(post['prompt']),
                          subtitle: Text(post['content']),
                          trailing: Text(
                            "${post['date'].day}-${post['date'].month}-${post['date'].year}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigoAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
