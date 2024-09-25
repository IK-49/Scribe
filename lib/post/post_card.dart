import 'package:flutter/material.dart';
import '../post/post.dart'; // Ensure this points to where the Post model is defined
import 'package:cloud_firestore/cloud_firestore.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Posted by ${post.user} on ${formatDate(post.createdAt)}",
              style: TextStyle(color: Colors.grey[600], fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              post.fullContent.length > 100
                  ? "${post.fullContent.substring(0, 100)}..." // Display a preview of the content
                  : post.fullContent, // Display full content if it's short
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  // A helper function to format the date from a Firestore Timestamp
  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.month}/${date.day}/${date.year}"; // Example format: MM/DD/YYYY
  }
}
