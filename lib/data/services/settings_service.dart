import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> clearAllRecords() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final userDoc = _firestore.collection('users').doc(user.uid);

    final dailySnapshot = await userDoc.collection('daily_records').get();
    for (final doc in dailySnapshot.docs) {
      await doc.reference.delete();
    }

    final mealSnapshot = await userDoc.collection('meal_records').get();
    for (final doc in mealSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}