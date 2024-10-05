import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../post/post.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int likeCount = 0;
  List<Map<String, String>> comments = [];

  @override
  void initState() {
    super.initState();
    fetchLikeStatus();
    fetchComments();
  }

  // Fetch the current like count and whether the user has liked the post
  void fetchLikeStatus() async {
    final postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .get();
    if (postSnapshot.exists) {
      setState(() {
        likeCount = postSnapshot['likeCount'] ?? 0;
        isLiked = postSnapshot['likedBy'].contains('currentUserId');
      });
    }
  }

  // Fetch the comments for the post
  void fetchComments() async {
    final commentSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();
    List<Map<String, String>> fetchedComments = [];
    for (var doc in commentSnapshot.docs) {
      fetchedComments.add({
        'text': doc['text'],
        'userId': doc['userId']
      });
    }
    setState(() {
      comments = fetchedComments;
    });
  }

  // Toggle the like status and update Firestore
  void toggleLike() async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

    if (isLiked) {
      await postRef.update({
        'likeCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove(['currentUserId']),
      });
      setState(() {
        isLiked = false;
        likeCount--;
      });
    } else {
      await postRef.update({
        'likeCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion(['currentUserId']),
      });
      setState(() {
        isLiked = true;
        likeCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      color: widget.post.color ?? Colors.grey[300], // Use the stored color, fallback to grey
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: const TextStyle(
                fontFamily: 'Georgia', // Serif font
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Posted by ${widget.post.user}",
              style: TextStyle(
                fontFamily: 'Georgia', // Serif font
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.content,
              style: const TextStyle(fontFamily: 'Georgia'), // Serif font
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: toggleLike,
                ),
                Text('$likeCount likes'),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    // Handle comment action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    // Handle share action
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Comment preview section with Instagram-like style
            if (comments.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var comment in comments)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Georgia', // Serif font
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: comment['userId'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: comment['text'],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ] else
              const Text('No comments yet'),
          ],
        ),
      ),
    );
  }
}
