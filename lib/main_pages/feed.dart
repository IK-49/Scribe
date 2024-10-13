import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../post/post.dart';
import '../post/post_card.dart';
import '../post/post_details.dart';
import 'package:http/http.dart' as http;

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  
  String prompt = '';

  @override
  void initState() {
    super.initState();
    fetchPrompt(); // Fetch the prompt when the widget is initialized
  }

  Future<void> fetchPrompt() async {
    final response = await http
        .get(Uri.parse('http://izadkhokhar.pythonanywhere.com/promptGenerate'));
    if (response.statusCode == 200) {
      setState(() {
        prompt = json.decode(response.body)['todaysPrompt'];
      });
    } else {
      throw Exception('Failed to load prompt');
    }
  }

  Stream<List<Post>> getPosts() {
    if (prompt.isEmpty) {
      return Stream.value([]); // Return an empty list while waiting for the prompt
    }
    print(prompt);
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .where('prompt', isEqualTo: prompt)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: getPosts(),
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
                    builder: (context) =>
                        PostDetails(post: post), // On tap of the card
                  ),
                );
              },
              child: PostCard(
                post: post,
                onCommentPressed: () {
                  // Navigate to PostDetails page when comment button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetails(post: post),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
