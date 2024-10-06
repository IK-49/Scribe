import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String user;
  final Timestamp createdAt;
  final Color? color;

  Post({
    required this.id,
    required this.title,
    required this.content, 
    required this.user,
    required this.createdAt,
    this.color, 
  });

  factory Post.fromJson(Map<String, dynamic> json, String id) {
    return Post(
      id: id,
      title: json['title'],
      content: json['fullContent'], 
      user: json['user'],
      createdAt: json['createdAt'],
      color: json['color'] != null ? Color(json['color']) : null, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'fullContent': content,
      'user': user,
      'createdAt': createdAt,
      'color': color?.value, 
    };
  }
}
