import 'package:flutter/material.dart';
import 'package:diet_quest_app/data/services/app_state.dart';
import 'package:diet_quest_app/data/services/daily_record_service.dart';

class DailyRecordPage extends StatefulWidget {
  const DailyRecordPage({super.key});

  @override
  State<DailyRecordPage> createState() => _DailyRecordPageState();
}

class _DailyRecordPageState extends State<DailyRecordPage> {
  final weightController = TextEditingController();
  final waistController = TextEditingController();
  final armController = TextEditingController();
  final thighController = TextEditingController();
  final calorieController = TextEditingController();

  final DailyRecordService _dailyRecordService = DailyRecordService();

  bool isPeriod = false;
  bool isLoading = false;

  @override
  void dispose() {
    weightController.dispose();
    waistController.dispose();
    armController.dispose();
    thighController.dispose();
    calorieController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    final weight = double.tryParse(weightController.text.trim()) ?? 0;
    final calories = double.tryParse(calorieController.text.trim()) ?? 0;
    final waist = double.tryParse(waistController.text.trim());
    final arm = double.tryParse(armController.text.trim());
    final thigh = double.tryParse(thighController.text.trim());

    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      setState(() {
        isLoading = true;
      });

      await _dailyRecordService.saveDailyRecord(
        date: date,
        weight: weight,
        calories: calories,
        waist: waist,
        arm: arm,
        thigh: thigh,
        isPeriod: isPeriod,
      );

      AppState.dailyRecords.insert(
        0,
        DailyRecordItem(
          date: date,
          weight: weight,
          calories: calories,
          waist: waist,
          arm: arm,
          thigh: thigh,
          isPeriod: isPeriod,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('일일 기록이 저장되었습니다.'),
        ),
      );

      Navigator.pop(context);
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('일일 기록 저장 실패: $e'),
        ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateText =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('일일 기록 입력'),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 기록',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dateText,
                          style: const TextStyle(
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
                          _buildSectionTitle('기본 기록'),
                          const SizedBox(height: 20),
                          _buildNumberField(
                            label: '오늘 체중 (kg)',
                            controller: weightController,
                            icon: Icons.monitor_weight_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildNumberField(
                            label: '총 섭취 칼로리',
                            controller: calorieController,
                            icon: Icons.local_fire_department_outlined,
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            value: isPeriod,
                            onChanged: (value) {
                              setState(() {
                                isPeriod = value;
                              });
                            },
                            title: const Text('생리 여부'),
                            subtitle: const Text('해당 시 활성화하세요'),
                            secondary: const Icon(Icons.favorite_border),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionTitle('신체 치수'),
                          const SizedBox(height: 20),
                          _buildNumberField(
                            label: '허리 둘레',
                            controller: waistController,
                            icon: Icons.straighten,
                          ),
                          const SizedBox(height: 16),
                          _buildNumberField(
                            label: '팔 둘레',
                            controller: armController,
                            icon: Icons.fitness_center,
                          ),
                          const SizedBox(height: 16),
                          _buildNumberField(
                            label: '허벅지 둘레',
                            controller: thighController,
                            icon: Icons.directions_walk,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveRecord,
                    child: Text(isLoading ? '저장 중...' : '저장'),
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