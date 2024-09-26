import 'package:Scribe/post/post_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../post/post.dart';
import '../post/post_details.dart'; // Import the PostDetails screen
import '../post/new_post.dart'; // Assuming you're using this somewhere

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String feed = '';
  List<Post> posts = [];
  String selectedFilter = 'Recent'; // Default filter option

  @override
  void initState() {
    super.initState();
    // No need to call getPosts() here since StreamBuilder will handle it
  }

  Stream<List<Post>> getPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Post.fromJson(doc.data(), doc.id)) // Pass doc.id if needed
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Post>>(
        stream: getPosts(), // Listening to Firestore updates
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data ?? [];

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetails(post: post),
                    ),
                  );
                },
                child:
                    PostCard(post: post), // Ensure PostCard widget is defined
              );
            },
          );
        },
      ),
    );
  }
}
