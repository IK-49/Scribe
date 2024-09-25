import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:http/http.dart' as http;
import 'package:Scribe/main_pages/main_page.dart';
import 'dart:convert';
import '../main_pages/feed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final TextEditingController _titleController = TextEditingController();


  Future<void> _submitPost() async {
  final postContent = _controller.document.toPlainText();
  final postTitle = _titleController.text;
  final preview = postContent.length > 30 ? postContent.substring(0, 30) + '...' : postContent;

  // Get the current user
  final user = FirebaseAuth.instance.currentUser?.displayName.toString();

  // Reference to Firestore collection
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  // Add post to Firestore
  await posts.add({
    'user': user,
    'title': postTitle,
    'preview': preview,
    'fullContent': postContent,
    'createdAt': Timestamp.now(),
  }).then((value) {
    print('Post Added');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }).catchError((error) {
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
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Post Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
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
            QuillSimpleToolbar(
              controller: _controller,
              configurations: const QuillSimpleToolbarConfigurations(),
            ),
            SizedBox(height: 20),
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
