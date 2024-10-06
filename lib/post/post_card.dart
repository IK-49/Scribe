import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Import Share Plus
import '../post/post.dart';
import '../post/post_details.dart'; // Import the PostDetails page

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onCommentPressed; // Add callback for comment button

  const PostCard({Key? key, required this.post, required this.onCommentPressed}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    fetchLikeStatus();
  }

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

  // Share post logic
  void sharePost() {
    Share.share(widget.post.content);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      color: widget.post.color ?? Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Posted by ${widget.post.user}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
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
                  icon: const Icon(Icons.comment),
                  onPressed: widget.onCommentPressed, // Navigate to comments
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: sharePost, // Native sharing
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
