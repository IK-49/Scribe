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

  @override
  void initState() {
    super.initState();
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
        isLiked = postSnapshot['likedBy'].contains('currentUserId');
      });
    }
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
                    Text('$likeCount likes'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
