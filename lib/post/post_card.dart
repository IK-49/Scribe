import 'package:Scribe/post/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Import Share Plus

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onCommentPressed;

  const PostCard({Key? key, required this.post, required this.onCommentPressed})
      : super(key: key);

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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .get();
    if (postSnapshot.exists) {
      final likedBy = List.from(postSnapshot['likedBy'] ?? []);
      setState(() {
        likeCount = postSnapshot['likeCount'] ?? 0;
        isLiked = likedBy.contains(userId);
      });
    }
  }

  bool isProcessing = false;

  void toggleLike() async {
    if (isProcessing) return;
    isProcessing = true;

    final userId =
        FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
    if (userId == null) return; // If the user is not logged in, do nothing

    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

    if (isLiked) {
      await postRef.update({
        'likeCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]), // Use actual user ID
      });
      setState(() {
        isLiked = false;
        likeCount--;
      });
    } else {
      await postRef.update({
        'likeCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]), // Use actual user ID
      });
      setState(() {
        isLiked = true;
        likeCount++;
      });
    }

    Future.delayed(Duration(milliseconds: 300), () {
      isProcessing = false;
    });
  }

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
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align buttons to the right
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
