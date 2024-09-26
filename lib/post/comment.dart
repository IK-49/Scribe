import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentPage extends StatefulWidget {
  final String postId;

  CommentPage({required this.postId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to free up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var comment = comments[index]['text'];
                    return ListTile(
                      title: Text(comment),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller, // Assign the controller here
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  // Post the comment if the input is not empty
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .add({
                    'text': value,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  _controller.clear(); // Clear the input field after submission
                }
              },
              decoration: InputDecoration(
                labelText: 'Add a comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
