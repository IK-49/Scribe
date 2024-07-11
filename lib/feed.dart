import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'post.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String feed = '';
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    // final response = await http.get(Uri.parse("http://127.0.0.1:5000/posts.json"));
    //TODO: temporary json for testing; we'll replace it later when we implement the server
    final response = '''[
      {
        "user": "Aakash",
        "title": "Battlefield 2042",
        "preview": "hi im aakash i love fortnite"
      },
      {
        "user": "Nathan Manoj Jacob",
        "title": "A Day in the Life of Nathan Manoj Jacob",
        "preview": "Today, I want to share a day in my life..."
      },
      {
        "user": "Aarik",
        "title": "how to backend",
        "preview": "step 1: http request, step 2: cry"
      },
      {
        "user": "Izad",
        "title": "The rise of the broken sigma (me)",
        "preview": "how i became a sigma cool"
      }
    ]''';

    // if (response.statusCode == 200) {
    final List<dynamic> postJson = json.decode(response /*.body*/);
    setState(() {
      posts = postJson.map((json) => Post.fromJson(json)).toList();
    });
    /* } else {
      // error handling here
    } */
  }

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
              // we need error handling here if the client doesn't connect with the server
              final response =
                  await http.get(Uri.parse("http://127.0.0.1:5000/pick"));
              final decoded =
                  json.decode(response.body) as Map<String, dynamic>;
              setState(() {
                feed = decoded['todaysPick'];
              });
            },
            child: const Text("Click to reveal todays prompt."),
          ),
          Expanded(
              //TODO: Add a refresh posts button as right now the list only updates after logging in 
              child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                        margin: const EdgeInsets.all(10.0),
                        child: ListTile(
                            title: Text(post.title),
                            subtitle: Text(post.preview),
                            leading: CircleAvatar(
                              //TODO: if no profile picture, use first letter of user, otherwise use profile picture
                              child: Text(post.user[0].toUpperCase()),
                            )));
                  })),
        ],
      ),
    );
  }
}
