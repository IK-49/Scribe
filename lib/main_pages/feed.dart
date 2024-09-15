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
    final response = await http
        .get(Uri.parse("https://aarikg.pythonanywhere.com/responses"));

    if (response.statusCode == 200) {
      final List<dynamic> postJson = json.decode(response.body);
      setState(() {
        posts = postJson.map((json) => Post.fromJson(json)).toList();
      });
    } else {
      // Handle error
      print('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
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
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
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
                                "Posted on Aug 18, 2024",
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
