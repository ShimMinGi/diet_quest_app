import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardSummary {
  final double? latestWeight;
  final int dailyRecordCount;
  final int mealRecordCount;

  const DashboardSummary({
    required this.latestWeight,
    required this.dailyRecordCount,
    required this.mealRecordCount,
  });
}

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DashboardSummary> getDashboardSummary() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final userDoc = _firestore.collection('users').doc(user.uid);

    final dailySnapshot = await userDoc
        .collection('daily_records')
        .orderBy('createdAt', descending: true)
        .get();

    final mealSnapshot = await userDoc
        .collection('meal_records')
        .get();

    double? latestWeight;

    if (dailySnapshot.docs.isNotEmpty) {
      final latestData = dailySnapshot.docs.first.data();
      final weightValue = latestData['weight'];

      if (weightValue is num) {
        latestWeight = weightValue.toDouble();
      }
    }

    return DashboardSummary(
      latestWeight: latestWeight,
      dailyRecordCount: dailySnapshot.docs.length,
      mealRecordCount: mealSnapshot.docs.length,
    );
  }
}