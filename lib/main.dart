import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:writing_feed_app/landing_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({Key? key}) : super(key: key); // Constructor corrected

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Writing Feed App",
      home: LandingPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(color: Colors.cyan),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
  