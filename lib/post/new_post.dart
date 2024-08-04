import 'package:flutter/material.dart';

class NewPost extends StatelessWidget {
  NewPost({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "New Post",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your post',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print(_controller.text);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
