import 'dart:math';

import 'package:Scribe/post/comment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
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

  @override
  void initState() {
    super.initState();
    // Fetch initial like status and like count from Firestore
    fetchLikeStatus();
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
        isLiked = postSnapshot['likedBy'].contains('currentUserId'); // Replace 'currentUserId' with the actual user ID
      });
    }
  }

  // Toggle the like status and update Firestore
  void toggleLike() async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

    if (isLiked) {
      // If post is already liked, unlike it
      await postRef.update({
        'likeCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove(['currentUserId']),
      });
      setState(() {
        isLiked = false;
        likeCount--;
      });
    } else {
      // Like the post
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

  // Share the post using the 'share_plus' package
  void sharePost() {
    Share.share('${widget.post.title}\n${widget.post.content}');
  }

  // Navigate to comments page
  void openComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentPage(postId: widget.post.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> postColors = [
      Color(0xFFB3E5FC), // Light Blue
      Color(0xFFF8BBD0), // Light Pink
      Color(0xFFC8E6C9), // Light Green
      Color(0xFFFFF9C4), // Light Yellow
      Color(0xFFE1BEE7), // Light Lavender
    ];

    final Random random = Random();
    final Color randomColor = postColors[random.nextInt(postColors.length)];
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
      color: randomColor,
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
            // Like, Comment, and Share Row
            Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: toggleLike,
                    ),
                    Text('$likeCount likes'),
                  ],
                ),
                // Comment button
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: openComments,
                ),
                // Share button
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: sharePost,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
