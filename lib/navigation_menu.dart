import 'package:flutter/material.dart';
import 'package:writing_feed_app/feed.dart';
import 'package:writing_feed_app/new_post.dart';
import 'notifications.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {

  int currentIndex = 0;

  List pages = [Feed(), NewPost(), Notifications()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.feed), label: ""),
      ],),
      body: Center(
        child: Text("ok"),
      ),
    );
  }
}