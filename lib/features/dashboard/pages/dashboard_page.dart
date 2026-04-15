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
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 21,
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
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
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
                actions: [
                  IconButton(
                    onPressed: () async {
                      await AppStateLogoutHelper.signOut(context);
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF66BB6A),
                                  Color(0xFF43A047),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$userName의 Diet Quest',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '오늘도 한 칸 전진해볼까요?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '퀘스트 진행도',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(999),
                                        child: LinearProgressIndicator(
                                          value: progressValue,
                                          minHeight: 12,
                                          backgroundColor: Colors.white24,
                                          valueColor:
                                              const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${(progressValue * 100).toStringAsFixed(0)}% 진행',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          GridView.count(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 700 ? 2 : 1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 3.2,
                            children: [
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
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '바로가기',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildActionButton(
                            context,
                            label: '일일 기록 입력',
                            subtitle: '오늘의 체중과 칼로리를 기록하세요',
                            icon: Icons.edit_note,
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRouter.dailyRecord,
                              );
                              if (!mounted) return;
                              await _refreshDashboard();
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            context,
                            label: '식단 기록 입력',
                            subtitle: '식사 종류와 영양 정보를 남겨보세요',
                            icon: Icons.restaurant_menu,
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRouter.mealRecord,
                              );
                              if (!mounted) return;
                              await _refreshDashboard();
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            context,
                            label: '기록 보기',
                            subtitle: '저장한 일일 기록과 식단 기록을 확인하세요',
                            icon: Icons.list_alt,
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRouter.records,
                              );
                              if (!mounted) return;
                              await _refreshDashboard();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}