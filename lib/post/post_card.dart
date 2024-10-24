import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Scribe/post/post.dart';
import 'package:share_plus/share_plus.dart'; // Import Share Plus package

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

  void toggleLike() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final postRef = FirebaseFirestore.instance
      .collection('posts')
      .doc(widget.post.id);

  final postSnapshot = await postRef.get();

  // Ensure likeCount field exists before proceeding
  if (postSnapshot.exists) {
    final int currentLikeCount = postSnapshot.data()?['likeCount'] ?? 0;
    final likedBy = List.from(postSnapshot['likedBy'] ?? []);

    if (isLiked) {
      // Ensure the likeCount doesn't go below 0
      if (currentLikeCount > 0) {
        await postRef.update({
          'likeCount': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      }
      setState(() {
        isLiked = false;
        if (likeCount > 0) {
          likeCount--;
        }
      });
    } else {
      await postRef.update({
        'likeCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
      setState(() {
        isLiked = true;
        likeCount++;
      });
    }
  }
}


  void sharePost() {
    Share.share(widget.post.content);  // Share the post content
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: widget.post.color ?? Colors.grey[200], // Post color restored
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Posted by ${widget.post.displayName}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              widget.post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: toggleLike,
                    ),
                    Text('$likeCount likes'), // "likes" is now next to the count
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: widget.onCommentPressed,
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: sharePost,  // Share button to share post content
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
