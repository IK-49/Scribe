import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content; // This should map to 'fullContent'
  final String user;
  final Timestamp createdAt;
  final Color? color;

  Post({
    required this.id,
    required this.title,
    required this.content, // Should use 'fullContent' from Firestore
    required this.user,
    required this.createdAt,
    this.color, // Optional color field
  });

  // Factory to create a Post from JSON, parsing color from Firestore
  factory Post.fromJson(Map<String, dynamic> json, String id) {
    return Post(
      id: id,
      title: json['title'],
      content: json['fullContent'], // Map 'fullContent' instead of 'content'
      user: json['user'],
      createdAt: json['createdAt'],
      color: json['color'] != null ? Color(json['color']) : null, // Parse color from Firestore
    );
  }

  // Convert the Post object to a Map to store in Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'fullContent': content,
      'user': user,
      'createdAt': createdAt,
      'color': color?.value, // Store color as an integer in Firestore
    };
  }
}
