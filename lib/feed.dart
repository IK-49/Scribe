import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String feed = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            feed,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Align(alignment: Alignment.center, child: Text(feed)),
          ElevatedButton(
            onPressed: () async {
              print("button pressed");
              final response = await http.get(Uri.parse("http://127.0.0.1:5000/pick"));
              final decoded = json.decode(response.body) as Map<String, dynamic>;
              setState(() {
                feed = decoded['todaysPick'];
              });
            },
            child: const Text("Click to reveal todays prompt."),
          ),
        ],
      ),
    );
  }
}
