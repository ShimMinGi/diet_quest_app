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
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
    const mealTypes = [
      '새벽',
      '아침',
      '오전 간식',
      '점심',
      '오후 간식',
      '저녁',
      '야식',
    ];

    final now = DateTime.now();
    final dateText =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('식단 기록 입력'),
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
                          '오늘의 식단 기록',
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
                          _buildSectionTitle('기본 정보'),
                          const SizedBox(height: 20),
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
                              prefixIcon: Icon(Icons.restaurant_menu),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: '식단 설명',
                            controller: descriptionController,
                            icon: Icons.notes,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: '칼로리',
                            controller: caloriesController,
                            icon: Icons.local_fire_department_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
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
                          _buildSectionTitle('영양 정보'),
                          const SizedBox(height: 20),
                          _buildField(
                            label: '탄수화물 (g)',
                            controller: carbsController,
                            icon: Icons.rice_bowl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: '단백질 (g)',
                            controller: proteinController,
                            icon: Icons.egg_alt,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: '지방 (g)',
                            controller: fatController,
                            icon: Icons.opacity,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveMeal,
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