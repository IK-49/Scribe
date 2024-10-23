import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'streak_service.dart';

class StreakCalendar extends StatefulWidget {
  @override
  _StreakCalendarState createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _streakDays = {};
  int streakCount = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId;
  StreakService _streakService = StreakService();

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? 'null';
    _fetchStreaks();
  }

  Future<void> _fetchStreaks() async {
    if (userId == 'null') {
      print("User not logged in");
      return;
    }

    DocumentSnapshot userDoc = await _firestore.collection('streaks').doc(userId).get();
    if (userDoc.exists) {
      int fetchedStreakCount = userDoc.get('currentStreakCount') ?? 0;
      List<dynamic> streakDays = userDoc.get('streakDays') ?? [];

      setState(() {
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
      print("User not logged in");
      return;
    }

    DateTime lastStreakDay;
    if (_streakDays.isNotEmpty) {
      lastStreakDay = _streakDays.reduce((a, b) => a.isAfter(b) ? a : b);
    } else {
      lastStreakDay = DateTime.now();
    }

    DateTime nextStreakDay = lastStreakDay.add(const Duration(days: 1));

    streakCount += 1;
    _streakDays.add(nextStreakDay);

    List<String> streakDaysList = _streakDays.map((day) => day.toIso8601String()).toList();

    await _firestore.collection('streaks').doc(userId).update({
      'currentStreakCount': streakCount,
      'streakDays': streakDaysList,
      'lastActiveDate': nextStreakDay,
    });

    setState(() {
      _focusedDay = nextStreakDay;
    });

    print("Streak updated. New streak day: $nextStreakDay");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Calendar'),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Text(
                '$streakCount 🔥',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigoAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Calendar
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
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _testStreakUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              ),
              child: const Text('Test Streak Update', style: TextStyle(color: Colors.white),),
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
      decoration: const BoxDecoration(
        color: Colors.green, // Streak days color
        shape: BoxShape.circle,
      ),
      child: Text(
        '${day.day}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildTodayMarker(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.blue, // Today's date color
        shape: BoxShape.circle,
      ),
      child: Text(
        '${day.day}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
