import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content; // This should map to 'fullContent'
  final String user;
  final Timestamp createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content, // Should use 'fullContent' from Firestore
    required this.user,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json, String id) {
    return Post(
      id: id,
      title: json['title'],
      content: json['fullContent'], // Map 'fullContent' instead of 'content'
      user: json['user'],
      createdAt: json['createdAt'],
    );
  }
}
