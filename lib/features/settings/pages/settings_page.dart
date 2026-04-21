import 'package:flutter/material.dart';
import 'package:diet_quest_app/core/router/app_router.dart';
import 'package:diet_quest_app/data/services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settingsService = SettingsService();

  bool isClearing = false;

  Future<void> _confirmClearAllRecords() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('전체 기록 초기화'),
          content: const Text(
            '일일 기록과 식단 기록이 모두 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.\n계속하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      setState(() {
        isClearing = true;
      });

      await _settingsService.clearAllRecords();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전체 기록이 초기화되었습니다.')),
      );
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기록 초기화 실패: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isClearing = false;
      });
    }
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF2E7D32),
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '설정',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '계정과 기록 관련 기능을 관리할 수 있어요',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMenuTile(
                    icon: Icons.lock_outline,
                    title: '비밀번호 변경',
                    subtitle: '로그인 비밀번호를 변경합니다',
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.changePassword);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    icon: Icons.track_changes_outlined,
                    title: '목표 재설정',
                    subtitle: '목표 체중과 계획을 다시 설정합니다',
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.resetGoal);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    icon: Icons.delete_sweep_outlined,
                    title: isClearing ? '초기화 진행 중...' : '전체 기록 초기화',
                    subtitle: '저장된 기록을 모두 삭제합니다',
                    onTap: isClearing ? () {} : _confirmClearAllRecords,
                    iconColor: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    icon: Icons.person_remove_outlined,
                    title: '회원 탈퇴',
                    subtitle: '계정 및 데이터를 삭제합니다',
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.deleteAccount);
                    },
                    iconColor: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}