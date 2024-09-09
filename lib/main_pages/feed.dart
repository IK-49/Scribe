import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:writing_feed_app/login_pages/landing_page.dart';
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
    // } else { //error handling }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 107, 99, 255),
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
          Align(
            alignment: Alignment.topRight,
            child: Text("Current User ID: " +
                FirebaseAuth.instance.currentUser!.email.toString()),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LandingPage()));
            },
            child: Text("Sign Out"),
          ),
          ElevatedButton(
            onPressed: () async {
              print("button pressed");

              final response = await http
                  .get(Uri.parse('https://aarikg.pythonanywhere.com/pick'));
              Map json = jsonDecode(response.body);
              setState(() {
                feed = json['todaysPick'];
              });
            },
            child: const Text("Click to reveal today's prompt."),
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
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                child: Text(post.user[0].toUpperCase()),
                                radius: 20.0,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                post.user,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "Posted on Aug 18, 2024", // Replace with actual date
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            post.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            post.preview,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.thumb_up),
                                onPressed: () {
                                  // Like action
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.comment),
                                onPressed: () {
                                  // Comment action
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () {
                                  // Share action
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
