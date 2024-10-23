import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateStreak({DateTime? testDate}) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) return; // User is not logged in

    // Reference to the user's streak document
    DocumentReference streakRef = _firestore.collection('streaks').doc(userId);

    // Fetch the current streak data
    DocumentSnapshot snapshot = await streakRef.get();
    Map<String, dynamic>? streakData = snapshot.data() as Map<String, dynamic>?;

    // Use the test date if provided, otherwise default to the current date
    DateTime now = testDate ?? DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    List<String> streakDays = [];
    if (streakData != null && streakData.containsKey('streakDays')) {
      streakDays = List<String>.from(streakData['streakDays']);
    }

    // If no streak data exists, create a new streak document
    if (streakData == null) {
      await streakRef.set({
        'startDate': today,
        'lastActiveDate': today,
        'currentStreakCount': 1,
        'bestStreakCount': 1,
        'streakDays': [today.toIso8601String()],  // Add streakDays with today's date
      });
    } else {
      DateTime lastActiveDate = (streakData['lastActiveDate'] as Timestamp).toDate();
      int currentStreakCount = streakData['currentStreakCount'] ?? 0;
      int bestStreakCount = streakData['bestStreakCount'] ?? 0;

      // Check if the streak should be updated
      if (lastActiveDate.isBefore(today)) {
        if (lastActiveDate.difference(today).inDays == -1) {
          // Increment streak count if it was active yesterday
          currentStreakCount += 1;
          bestStreakCount = (currentStreakCount > bestStreakCount)
              ? currentStreakCount
              : bestStreakCount;
        } else {
          // Reset the current streak if more than a day has passed
          currentStreakCount = 1;
        }

        // Add today's date to the streakDays array
        streakDays.add(today.toIso8601String());

        // Update the Firestore document with the new streak data
        await streakRef.update({
          'currentStreakCount': currentStreakCount,
          'bestStreakCount': bestStreakCount,
          'lastActiveDate': today,
          'streakDays': streakDays,  // Update streakDays in Firestore
        });
      }
    }
  }
}
