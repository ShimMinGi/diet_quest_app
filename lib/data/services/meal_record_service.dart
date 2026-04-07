import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveMealRecord({
    required String date,
    required String mealType,
    required String description,
    required double calories,
    required double carbs,
    required double protein,
    required double fat,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('meal_records')
        .add({
      'date': date,
      'mealType': mealType,
      'description': description,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}