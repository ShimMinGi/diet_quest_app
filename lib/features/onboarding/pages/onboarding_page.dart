import 'package:flutter/material.dart';
import 'package:diet_quest_app/data/models/user_profile_model.dart';
import 'package:diet_quest_app/data/services/user_service.dart';
import 'package:diet_quest_app/features/dashboard/pages/dashboard_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final nameController = TextEditingController();
  final heightController = TextEditingController();
  final startWeightController = TextEditingController();
  final goalWeightController = TextEditingController();

  final UserService _userService = UserService();

  String selectedGender = '남성';
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    heightController.dispose();
    startWeightController.dispose();
    goalWeightController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final name = nameController.text.trim();
    final height = double.tryParse(heightController.text.trim()) ?? 0;
    final startWeight = double.tryParse(startWeightController.text.trim()) ?? 0;
    final goalWeight = double.tryParse(goalWeightController.text.trim()) ?? 0;

    final userProfile = UserProfileModel(
      name: name.isEmpty ? '사용자' : name,
      gender: selectedGender,
      height: height,
      startWeight: startWeight,
      goalWeight: goalWeight,
    );

    try {
      setState(() {
        isLoading = true;
      });

      await _userService.saveUserProfile(userProfile);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(userProfile: userProfile),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('온보딩 저장 실패: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('온보딩'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '기본 정보를 입력해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedGender,
              items: const [
                DropdownMenuItem(value: '남성', child: Text('남성')),
                DropdownMenuItem(value: '여성', child: Text('여성')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedGender = value;
                });
              },
              decoration: const InputDecoration(
                labelText: '성별',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '키(cm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: startWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '시작 체중(kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: goalWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '목표 체중(kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _completeOnboarding,
              child: Text(isLoading ? '저장 중...' : '완료'),
            ),
          ],
        ),
      ),
    );
  }
}