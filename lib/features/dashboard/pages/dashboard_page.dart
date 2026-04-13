import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diet_quest_app/core/router/app_router.dart';
import 'package:diet_quest_app/data/models/user_profile_model.dart';
import 'package:diet_quest_app/data/services/dashboard_service.dart';
import 'package:diet_quest_app/data/services/user_service.dart';

class AppStateLogoutHelper {
  static Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.login,
      (route) => false,
    );
  }
}

class DashboardPage extends StatefulWidget {
  final UserProfileModel? userProfile;

  const DashboardPage({
    super.key,
    this.userProfile,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final UserService _userService = UserService();
  final DashboardService _dashboardService = DashboardService();

  late Future<UserProfileModel?> _profileFuture;
  late Future<DashboardSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _userService.getUserProfile();
    _summaryFuture = _dashboardService.getDashboardSummary();
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _profileFuture = _userService.getUserProfile();
      _summaryFuture = _dashboardService.getDashboardSummary();
    });
  }

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
    return FutureBuilder<UserProfileModel?>(
      future: _profileFuture,
      builder: (context, profileSnapshot) {
        return FutureBuilder<DashboardSummary>(
          future: _summaryFuture,
          builder: (context, summarySnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting ||
                summarySnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (profileSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('대시보드'),
                  centerTitle: true,
                ),
                body: Center(
                  child: Text('프로필 불러오기 실패: ${profileSnapshot.error}'),
                ),
              );
            }

            if (summarySnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('대시보드'),
                  centerTitle: true,
                ),
                body: Center(
                  child: Text('대시보드 데이터 불러오기 실패: ${summarySnapshot.error}'),
                ),
              );
            }

            final profile = profileSnapshot.data ?? widget.userProfile;
            final summary = summarySnapshot.data ??
                const DashboardSummary(
                  latestWeight: null,
                  dailyRecordCount: 0,
                  mealRecordCount: 0,
                );

            final userName = profile?.name ?? '사용자';
            final currentWeight =
                summary.latestWeight ?? profile?.startWeight ?? 0.0;
            final goalWeight = profile?.goalWeight ?? 0.0;

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
                actions: [
                  IconButton(
                    onPressed: () async {
                      await AppStateLogoutHelper.signOut(context);
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
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
                          '${profile?.gender ?? '남성'} / ${_formatDouble(profile?.height ?? 0)} cm',
                      icon: Icons.person,
                    ),
                    _buildInfoCard(
                      title: '일일 기록 개수',
                      value: '${summary.dailyRecordCount}개',
                      icon: Icons.edit_note,
                    ),
                    _buildInfoCard(
                      title: '식단 기록 개수',
                      value: '${summary.mealRecordCount}개',
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
                        if (!mounted) return;
                        await _refreshDashboard();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      context,
                      label: '식단 기록 입력',
                      icon: Icons.restaurant_menu,
                      onPressed: () async {
                        await Navigator.pushNamed(context, AppRouter.mealRecord);
                        if (!mounted) return;
                        await _refreshDashboard();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      context,
                      label: '기록 보기',
                      icon: Icons.list_alt,
                      onPressed: () async {
                        await Navigator.pushNamed(context, AppRouter.records);
                        if (!mounted) return;
                        await _refreshDashboard();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}