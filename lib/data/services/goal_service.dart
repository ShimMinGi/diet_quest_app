import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateGoal({
    required double goalWeight,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'goalWeight': goalWeight,
      'goalUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}