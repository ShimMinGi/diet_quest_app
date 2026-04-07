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
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('일일 기록'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '날짜: ${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildNumberField(
              label: '오늘 체중 (kg)',
              controller: weightController,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: '허리 둘레',
              controller: waistController,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: '팔 둘레',
              controller: armController,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: '허벅지 둘레',
              controller: thighController,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: '총 섭취 칼로리',
              controller: calorieController,
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
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _saveRecord,
              child: Text(isLoading ? '저장 중...' : '저장'),
            ),
          ],
        ),
      ),
    );
  }
}