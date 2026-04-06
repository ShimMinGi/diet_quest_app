import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diet_quest_app/data/models/user_profile_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserProfile(UserProfileModel profile) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'name': profile.name,
      'gender': profile.gender,
      'height': profile.height,
      'startWeight': profile.startWeight,
      'goalWeight': profile.goalWeight,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}