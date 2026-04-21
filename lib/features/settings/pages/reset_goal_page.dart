import 'package:flutter/material.dart';
import 'package:diet_quest_app/data/services/goal_service.dart';

class ResetGoalPage extends StatefulWidget {
  const ResetGoalPage({super.key});

  @override
  State<ResetGoalPage> createState() => _ResetGoalPageState();
}

class _ResetGoalPageState extends State<ResetGoalPage> {
  final goalWeightController = TextEditingController();
  final GoalService _goalService = GoalService();

  bool isLoading = false;

  @override
  void dispose() {
    goalWeightController.dispose();
    super.dispose();
  }

  Future<void> _resetGoal() async {
    final goalWeight = double.tryParse(goalWeightController.text.trim());

    if (goalWeight == null || goalWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 목표 체중을 입력해주세요.')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await _goalService.updateGoal(goalWeight: goalWeight);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('목표 체중이 재설정되었습니다.')),
      );

      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('목표 재설정 실패: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('목표 재설정'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
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
                          '목표 재설정',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '새로운 목표 체중을 설정하세요',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildNumberField(
                            label: '새 목표 체중(kg)',
                            controller: goalWeightController,
                            icon: Icons.flag_outlined,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : _resetGoal,
                            icon: const Icon(Icons.save),
                            label: Text(isLoading ? '저장 중...' : '재설정 완료'),
                          ),
                        ],
                      ),
                    ),
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