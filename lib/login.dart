import 'package:flutter/material.dart';
import 'feed.dart';
import 'package:http/http.dart' as http;
import "dart:convert";

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Center(
                child: Text("Login",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)))),
        body: Body());
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  void click() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Feed()));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: ElevatedButton(
            child: const Text("placeholder for google login"),
            onPressed: click));
  }
}
