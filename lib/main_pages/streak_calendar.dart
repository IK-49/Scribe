import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'streak_service.dart'; // Import your StreakService class here

class StreakCalendar extends StatefulWidget {
  @override
  _StreakCalendarState createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _streakDays = {};
  int streakCount = 0; // Initialize streak count to 0

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId; // Dynamically set user ID after auth

  StreakService _streakService =
      StreakService(); // Create an instance of StreakService

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? 'null'; // Get user ID
    _fetchStreaks();
  }

  Future<void> _fetchStreaks() async {
    if (userId == 'null') {
      print("User not logged in"); // Ensure user is logged in before fetching
      return;
    }

    DocumentSnapshot userDoc =
        await _firestore.collection('streaks').doc(userId).get();
    if (userDoc.exists) {
      // Fetch `currentStreakCount` from Firestore
      int fetchedStreakCount = userDoc.get('currentStreakCount') ?? 0;
      print(
          "Fetched currentStreakCount: $fetchedStreakCount"); // Debugging line

      // Fetch streak days for calendar display
      List<dynamic> streakDays = userDoc.get('streakDays') ?? [];

      setState(() {
        // Update the streak count and days in the UI
        streakCount = fetchedStreakCount;
        _streakDays = streakDays.map((day) => DateTime.parse(day)).toSet();
      });
    } else {
      print("No streak data found.");
    }
  }

  bool _isStreakDay(DateTime day) {
    return _streakDays.any((d) => isSameDay(d, day));
  }

  Future<void> _testStreakUpdate() async {
    if (userId == 'null') {
      print(
          "User not logged in"); // Ensure user is logged in before updating streak
      return;
    }

    // Call the StreakService to update the streak with a test date
    await _streakService.updateStreak(
        testDate: DateTime(2024, 10, 27)); // Example test date
    await _fetchStreaks(); // Fetch the updated streaks from Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Streak Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the streak count with a fire emoji
            Center(
              child: Text(
                '$streakCount 🔥',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Calendar display
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              // Disable day selection
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (_isStreakDay(day)) {
                    return _buildStreakMarker(day);
                  }
                  return null;
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildTodayMarker(day);
                },
              ),
            ),

            SizedBox(height: 20),

            // Button to test streak updates
            ElevatedButton(
              onPressed: _testStreakUpdate, // Trigger test streak update
              child: Text('Test Streak Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakMarker(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.green, // Color for streak days
        shape: BoxShape.circle,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildTodayMarker(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue, // Color for today's date
        shape: BoxShape.circle,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
