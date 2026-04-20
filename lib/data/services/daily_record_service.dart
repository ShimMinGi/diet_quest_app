import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveDailyRecord({
    required String date,
    required double weight,
    required double calories,
    double? waist,
    double? arm,
    double? thigh,
    required bool isPeriod,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_records')
        .add({
      'date': date,
      'weight': weight,
      'calories': calories,
      'waist': waist,
      'arm': arm,
      'thigh': thigh,
      'isPeriod': isPeriod,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDailyRecord({
    required String recordId,
    required String date,
    required double weight,
    required double calories,
    double? waist,
    double? arm,
    double? thigh,
    required bool isPeriod,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_records')
        .doc(recordId)
        .update({
      'date': date,
      'weight': weight,
      'calories': calories,
      'waist': waist,
      'arm': arm,
      'thigh': thigh,
      'isPeriod': isPeriod,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}