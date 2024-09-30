import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:Scribe/main_pages/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final TextEditingController _titleController = TextEditingController();

  // Function to submit the post to Firestore
  Future<void> _submitPost() async {
    final postContent = _controller.document.toPlainText(); // Get plain text content
    final postTitle = _titleController.text; // Get post title
    final preview = postContent.length > 30
        ? postContent.substring(0, 30) + '...'
        : postContent; // Create a preview of the post

    // Get the current logged-in user's display name
    final user = FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';

    // Reference to the Firestore collection 'posts'
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    // Add the post data to Firestore
    await posts.add({
      'user': user,
      'title': postTitle,
      'preview': preview,
      'fullContent': postContent,
      'createdAt': Timestamp.now(), // Store creation timestamp
      'likeCount': 0,
      'likedBy': "",
    }).then((value) {
      // Successfully added post, navigate to the main screen
      print('Post Added');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }).catchError((error) {
      // Error occurred during adding the post
      print("Failed to add post: $error");
    });
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
