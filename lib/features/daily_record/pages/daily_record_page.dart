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
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    weightController.dispose();
    waistController.dispose();
    armController.dispose();
    thighController.dispose();
    calorieController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }

  Future<void> _saveRecord() async {
    final weight = double.tryParse(weightController.text.trim());
    final calories = double.tryParse(calorieController.text.trim());
    final waist = waistController.text.trim().isEmpty
        ? null
        : double.tryParse(waistController.text.trim());
    final arm = armController.text.trim().isEmpty
        ? null
        : double.tryParse(armController.text.trim());
    final thigh = thighController.text.trim().isEmpty
        ? null
        : double.tryParse(thighController.text.trim());

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 체중을 입력해주세요.')),
      );
      return;
    }

    if (calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 칼로리를 입력해주세요.')),
      );
      return;
    }

    if (waist != null && waist < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('허리 둘레는 0 이상이어야 합니다.')),
      );
      return;
    }

    if (arm != null && arm < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('팔 둘레는 0 이상이어야 합니다.')),
      );
      return;
    }

    if (thigh != null && thigh < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('허벅지 둘레는 0 이상이어야 합니다.')),
      );
      return;
    }

    final date = _formatDate(selectedDate);

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
    final dateText = _formatDate(selectedDate);

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
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dateText,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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