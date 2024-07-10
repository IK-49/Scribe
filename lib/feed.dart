import 'package:flutter/material.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Center(
                child: Text("Feed",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)))),
        body: Column(
          children: <Widget>[
            Align(alignment: Alignment.center, child: Text("Hi")),
          ],
        ));
  }
}