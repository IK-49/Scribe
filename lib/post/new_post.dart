import 'dart:convert';
import 'dart:math';
import 'package:Scribe/main_pages/streak_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final TextEditingController _titleController = TextEditingController();

  // Generate a random pastel color
  Color getRandomPastelColor() {
    final random = Random();
    int randomIndex = random.nextInt(5);
    final List<Color> colors = [
      Color(0xFFB3E5FC), // Light Blue
      Color(0xFFF8BBD0), // Light Pink
      Color(0xFFC8E6C9), // Light Green
      Color(0xFFFFF9C4), // Light Yellow
      Color(0xFFE1BEE7), // Light Lavender
    ];

    return colors[randomIndex];
  }

  String prompt = '';

  Future<String> fetchPrompt() async {
    final response = await http
        .get(Uri.parse('http://izadkhokhar.pythonanywhere.com/promptGenerate'));
    if (response.statusCode == 200) {
      setState(() {
        prompt = json.decode(response.body)['todaysPrompt'];
      });
    } else {
      throw Exception('Failed to load prompt');
    }
    return prompt;
  }

// Function to submit the post to Firestore
  Future<void> _submitPost() async {
    final postContent =
        _controller.document.toPlainText(); // Get plain text content
    final postTitle = _titleController.text; // Get post title
    final preview = postContent.length > 30
        ? postContent.substring(0, 30) + '...'
        : postContent; // Create a preview of the post

    // Get the current logged-in user's userId and displayName
    final user = FirebaseAuth.instance.currentUser?.uid;
    final displayName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Someone';

    // Generate a random color for the post
    final color = getRandomPastelColor();

    // Reference to the Firestore collection 'posts'
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    // Add the post data to Firestore, including userId and displayName
    await posts.add({
      'user': user,
      'displayName': displayName,
      'title': postTitle,
      'preview': preview,
      'fullContent': postContent,
      'createdAt': Timestamp.now(),
      'likeCount': 0,
      'likedBy': [],
      'color': color.value,
      'prompt': await fetchPrompt(),
    }).then((value) {
      // Immediately pop back to the previous screen after the post is submitted
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to add post: $error");
    });

    final streakService = StreakService();
    streakService
        .updateStreak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "New Post",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input field for the post title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Post Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Quill editor for rich text post content
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: quill.QuillEditor.basic(
                  controller: _controller,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Quill toolbar for formatting options
            quill.QuillToolbar.simple(controller: _controller),
            SizedBox(height: 20),
            // Submit button
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
