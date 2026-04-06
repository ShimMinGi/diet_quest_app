import 'package:flutter/material.dart';
import 'package:diet_quest_app/core/router/app_router.dart';
import 'package:diet_quest_app/data/models/user_profile_model.dart';
import 'package:diet_quest_app/data/services/app_state.dart';

class DashboardPage extends StatelessWidget {
  final UserProfileModel? userProfile;

  const DashboardPage({
    super.key,
    this.userProfile,
  });

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  String _formatDouble(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final profile = userProfile;

    final userName = profile?.name ?? '민기';
    final currentWeight = AppState.dailyRecords.isNotEmpty
        ? AppState.dailyRecords.first.weight
        : (profile?.startWeight ?? 84.1);
    final goalWeight = profile?.goalWeight ?? 72.0;

    double progressValue = 0.0;
    if (profile != null) {
      final totalDiff = profile.startWeight - profile.goalWeight;
      final currentDiff = profile.startWeight - currentWeight;

      if (totalDiff > 0) {
        progressValue = (currentDiff / totalDiff).clamp(0.0, 1.0);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$userName의 Diet Quest',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '오늘도 한 칸 전진해볼까요?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: '현재 체중',
              value: '${_formatDouble(currentWeight)} kg',
              icon: Icons.monitor_weight,
            ),
            _buildInfoCard(
              title: '목표 체중',
              value: '${_formatDouble(goalWeight)} kg',
              icon: Icons.flag,
            ),
            _buildInfoCard(
              title: '성별 / 키',
              value:
                  '${profile?.gender ?? '남성'} / ${_formatDouble(profile?.height ?? 175)} cm',
              icon: Icons.person,
            ),
            _buildInfoCard(
              title: '일일 기록 개수',
              value: '${AppState.dailyRecords.length}개',
              icon: Icons.edit_note,
            ),
            _buildInfoCard(
              title: '식단 기록 개수',
              value: '${AppState.mealRecords.length}개',
              icon: Icons.restaurant_menu,
            ),
            const SizedBox(height: 16),
            const Text(
              '퀘스트 진행도',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              context,
              label: '일일 기록 입력',
              icon: Icons.edit_note,
              onPressed: () async {
                await Navigator.pushNamed(context, AppRouter.dailyRecord);
                (context as Element).markNeedsBuild();
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              label: '식단 기록 입력',
              icon: Icons.restaurant_menu,
              onPressed: () async {
                await Navigator.pushNamed(context, AppRouter.mealRecord);
                (context as Element).markNeedsBuild();
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              label: '기록 보기',
              icon: Icons.list_alt,
              onPressed: () async {
                await Navigator.pushNamed(context, AppRouter.records);
                (context as Element).markNeedsBuild();
              },
            ),
          ],
        ),
      ),
    );
  }
}