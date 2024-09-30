import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../post/post.dart';
import '../post/post_card.dart';
import '../post/post_details.dart';
import '../post/new_post.dart';
import 'package:http/http.dart' as http;

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  void initState() {
    super.initState();
    fetchPrompt();
  }

  Stream<List<Post>> getPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromJson(doc.data(), doc.id))
            .toList());
  }

  bool _isExpanded = false; // Controls the visibility of the prompt
  String todaysPrompt = "";

  Future<void> fetchPrompt() async {
    final response = await http.get(Uri.parse('http://izadkhokhar.pythonanywhere.com/promptGenerate'));
    if (response.statusCode == 200) {
      setState(() {
        todaysPrompt = json.decode(response.body)['todaysPrompt'];
      });
    } else {
      throw Exception('Failed to load prompt');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Button to show/hide prompt
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    backgroundColor: Colors.blue, // Customize button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                  ),
                  child: Text(
                    _isExpanded ? "Hide Today's Prompt" : "Show Today's Prompt",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              // Expanding box for the prompt
              if (_isExpanded)
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 224, 211, 211),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    todaysPrompt, // Display the fetched prompt here
                    style: TextStyle(
                      color: Colors.black, // Adjusted for readability
                      fontSize: 16,
                    ),
                  ),
                ),
              // StreamBuilder for posts
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
                          child: PostCard(post: post),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Overlay button to add a new post
          Positioned(
            bottom: 20, // Distance from the bottom of the screen
            right: 20, // Distance from the right of the screen
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NewPost()));
              },
              backgroundColor: Colors.blueAccent, // Customize button color
              child: const Icon(Icons.add, size: 30), // Icon size
            ),
          ),
        ],
      ),
    );
  }
}
