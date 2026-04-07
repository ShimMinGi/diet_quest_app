import 'package:flutter/material.dart';
import 'package:diet_quest_app/data/services/app_state.dart';
import 'package:diet_quest_app/data/services/meal_record_service.dart';

class MealRecordPage extends StatefulWidget {
  const MealRecordPage({super.key});

  @override
  State<MealRecordPage> createState() => _MealRecordPageState();
}

class _MealRecordPageState extends State<MealRecordPage> {
  String selectedMealType = '아침';

  final descriptionController = TextEditingController();
  final caloriesController = TextEditingController();
  final carbsController = TextEditingController();
  final proteinController = TextEditingController();
  final fatController = TextEditingController();

  final MealRecordService _mealRecordService = MealRecordService();

  bool isLoading = false;

  @override
  void dispose() {
    descriptionController.dispose();
    caloriesController.dispose();
    carbsController.dispose();
    proteinController.dispose();
    fatController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final calories = double.tryParse(caloriesController.text.trim()) ?? 0;
    final carbs = double.tryParse(carbsController.text.trim()) ?? 0;
    final protein = double.tryParse(proteinController.text.trim()) ?? 0;
    final fat = double.tryParse(fatController.text.trim()) ?? 0;

    try {
      setState(() {
        isLoading = true;
      });

      await _mealRecordService.saveMealRecord(
        date: date,
        mealType: selectedMealType,
        description: descriptionController.text.trim(),
        calories: calories,
        carbs: carbs,
        protein: protein,
        fat: fat,
      );

      AppState.mealRecords.insert(
        0,
        MealRecordItem(
          date: date,
          mealType: selectedMealType,
          description: descriptionController.text.trim(),
          calories: calories,
          carbs: carbs,
          protein: protein,
          fat: fat,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('식단 기록이 저장되었습니다.'),
        ),
      );

      Navigator.pop(context);
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('식단 기록 저장 실패: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mealTypes = [
      '새벽',
      '아침',
      '오전 간식',
      '점심',
      '오후 간식',
      '저녁',
      '야식',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('식단 기록'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedMealType,
              items: mealTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedMealType = value;
                });
              },
              decoration: const InputDecoration(
                labelText: '식사 종류',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildField(
              label: '식단 설명',
              controller: descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: '칼로리',
              controller: caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            _buildField(
              label: '탄수화물 (g)',
              controller: carbsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            _buildField(
              label: '단백질 (g)',
              controller: proteinController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            _buildField(
              label: '지방 (g)',
              controller: fatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _saveMeal,
              child: Text(isLoading ? '저장 중...' : '저장'),
            ),
          ],
        ),
      ),
    );
  }
}