// post_detail.dart
import 'package:flutter/material.dart';
import '../post/post.dart';

class PostDetails extends StatelessWidget {
  final Post post;

  const PostDetails({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              "Posted by ${post.user} on Aug 18, 2024",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Text(
              post.fullContent,  // Display the full content instead of preview
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
