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

  Future<UserProfileModel?> getUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;

    return UserProfileModel(
      name: data['name']?.toString() ?? '사용자',
      gender: data['gender']?.toString() ?? '남성',
      height: (data['height'] ?? 0).toDouble(),
      startWeight: (data['startWeight'] ?? 0).toDouble(),
      goalWeight: (data['goalWeight'] ?? 0).toDouble(),
    );
  }

  Future<bool> hasUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists;
  }
}