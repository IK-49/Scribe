import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../post/post.dart';
import '../post/new_post.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String feed = '';
  List<Post> posts = [];
  String selectedFilter = 'Recent'; // Default filter option

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
          // add debug button widget to refresh all stateful widgets
          Align(alignment: Alignment.center, child: Text(feed)),
          Align(
              alignment: Alignment.center,
              child: Text("Current User ID: " +
                  FirebaseAuth.instance.currentUser!.email.toString())),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Text("Sign Out"),
          ),
          ElevatedButton(
            onPressed: () async {
              print("button pressed");

              final response = await http
                  .get(Uri.parse('https://aarikg.pythonanywhere.com/pick'));
              print("1");
              Map json = jsonDecode(response.body);
              print("1");
              print(response.body);
              setState(() {
                feed = json['todaysPick'];
              });
            },
            child: const Text("Click to reveal todays prompt."),
          ),
          DropdownButton<String>(
            value: selectedFilter,
            items: <String>['Recent', 'Hot', 'Old'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedFilter = newValue!;
              });
              print('Current filter: $selectedFilter');
              // Add logic here to sort/filter posts based on selectedFilter
            },
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
          Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: MediaQuery.of(context).size.height * 0.15,
                  child: FittedBox(
                      child: IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => NewPost()));
                    },
                  )))),
        ],
      ),
    );
  }
}
