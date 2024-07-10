import 'package:flutter/material.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import "dart:convert";

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({Key? key}) : super(key: key); // Constructor corrected

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Writing Feed App",
      home: LoginPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(color: Colors.cyan),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
