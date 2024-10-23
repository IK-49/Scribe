import 'package:Scribe/post/post_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../post/post.dart';
import '../post/post_card.dart';
import '../post/new_post.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    return Column(
      children: [
        const SizedBox(height: 10),
        // Display Prompt at the top in a card/banner style
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.indigoAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      prompt.isNotEmpty
                          ? 'Today\'s Prompt: $prompt'
                          : 'Loading prompt...',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<List<Post>>(
            stream: getPosts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data ?? [];

              if (posts.isEmpty) {
                return const Center(child: Text('No posts available'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
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
                    child: PostCard(
                      post: post,
                      onCommentPressed: () {
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
          ),
        ),
        FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewPost()),
            );
          },
          backgroundColor: Colors.indigoAccent,
          child: const Icon(Icons.add),
          tooltip: 'Create New Post',
        ),
      ],
    );
  }
}
