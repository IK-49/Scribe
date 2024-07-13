import 'package:flutter/material.dart';

class NewPost extends StatelessWidget {
  const NewPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Center(
                child: Text("New Post",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)))),
        body: Text("Hi"));
  }
}
