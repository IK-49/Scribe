import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String title;
  final String fullContent;
  final String user;
  final Timestamp createdAt; // Firestore Timestamp

  Post({
    required this.title,
    required this.fullContent,
    required this.user,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'],
      fullContent: json['fullContent'],
      user: json['user'],
      createdAt: json['createdAt'],
    );
  }
}
