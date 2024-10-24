import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../post/post.dart';

class PostDetails extends StatefulWidget {
  final Post post;

  const PostDetails({super.key, required this.post});

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Method to add a new comment to Firestore
  Future<void> _addComment(String commentText) async {
    if (commentText.isNotEmpty) {
      await _firestore
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .add({
        'user': FirebaseAuth.instance.currentUser != null
            ? FirebaseAuth.instance.currentUser!.displayName.toString()
            : 'Guest',
        'comment': commentText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchComments() {
    return _firestore
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              "Posted by ${FirebaseAuth.instance.currentUser!.displayName.toString()} on ${DateFormat('MMM dd, yyyy').format(widget.post.createdAt.toDate())}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Text(
              widget.post.content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Divider(),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _fetchComments(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong!');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return Text('No comments yet. Be the first to comment!');
                  }
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final timestamp =
                          comment['createdAt']?.toDate() ?? DateTime.now();
                      return ListTile(
                        title: Text(comment['comment']),
                        subtitle: Text(
                          "Posted by ${comment['user']} on ${DateFormat('MMM dd, yyyy').format(timestamp)}",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Add comment text field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onSubmitted: (value) =>
                        _addComment(value), // Handle enter key press
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _addComment(_commentController.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
