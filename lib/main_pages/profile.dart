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
      // Fetch total posts made and likes received by the user
      QuerySnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: user!.uid)
          .get();

      setState(() {
        totalPosts = postSnapshot.docs.length;
        likesReceived = postSnapshot.docs
            .map((doc) => doc['likes'] ?? 0)
            .reduce((a, b) => a + b); // Calculate total likes
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchPostArchive() async {
    // Fetch posts made by the user on previous prompts
    QuerySnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: user!.uid)
        .orderBy('promptDate', descending: true)
        .get();

    // Map documents to a list of maps for easier rendering
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
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
                    : CircleAvatar(
                        child: Icon(Icons.person),
                        radius: 40,
                      ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Anonymous',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(user?.email ?? 'No email'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Post Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Posts', totalPosts),
                _buildStatCard('Likes Received', likesReceived),
              ],
            ),

            SizedBox(height: 20),

            // Post Archive
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchPostArchive(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No posts in the archive.'));
                  }

                  List<Map<String, dynamic>> posts = snapshot.data!;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        child: ListTile(
                          title: Text(post['prompt']),
                          subtitle: Text(post['content']),
                          trailing: Text(post['date'].toString()),
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
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
