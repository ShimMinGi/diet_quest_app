import 'package:flutter/material.dart';
import 'package:diet_quest_app/data/services/meal_record_service.dart';

class EditMealRecordPage extends StatefulWidget {
  final Map<String, dynamic> record;

  const EditMealRecordPage({
    super.key,
    required this.record,
  });

  @override
  State<EditMealRecordPage> createState() => _EditMealRecordPageState();
}

class _EditMealRecordPageState extends State<EditMealRecordPage> {
  String selectedMealType = '아침';

  final descriptionController = TextEditingController();
  final caloriesController = TextEditingController();
  final carbsController = TextEditingController();
  final proteinController = TextEditingController();
  final fatController = TextEditingController();

  final MealRecordService _mealRecordService = MealRecordService();

  bool isLoading = false;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    selectedMealType = widget.record['mealType']?.toString() ?? '아침';
    descriptionController.text = widget.record['description']?.toString() ?? '';
    caloriesController.text = widget.record['calories']?.toString() ?? '';
    carbsController.text = widget.record['carbs']?.toString() ?? '';
    proteinController.text = widget.record['protein']?.toString() ?? '';
    fatController.text = widget.record['fat']?.toString() ?? '';

    final dateString = widget.record['date']?.toString();
    if (dateString != null && dateString.contains('-')) {
      final parts = dateString.split('-');
      selectedDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } else {
      selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    caloriesController.dispose();
    carbsController.dispose();
    proteinController.dispose();
    fatController.dispose();
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

  Future<void> _updateMeal() async {
    final recordId = widget.record['id']?.toString();
    final description = descriptionController.text.trim();
    final calories = double.tryParse(caloriesController.text.trim());
    final carbs = carbsController.text.trim().isEmpty
        ? 0.0
        : (double.tryParse(carbsController.text.trim()) ?? -1);
    final protein = proteinController.text.trim().isEmpty
        ? 0.0
        : (double.tryParse(proteinController.text.trim()) ?? -1);
    final fat = fatController.text.trim().isEmpty
        ? 0.0
        : (double.tryParse(fatController.text.trim()) ?? -1);

    if (recordId == null || recordId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기록 ID를 찾을 수 없습니다.')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('식단 설명을 입력해주세요.')),
      );
      return;
    }

    if (calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 칼로리를 입력해주세요.')),
      );
      return;
    }

    if (carbs < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('탄수화물은 0 이상이어야 합니다.')),
      );
      return;
    }

    if (protein < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('단백질은 0 이상이어야 합니다.')),
      );
      return;
    }

    if (fat < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지방은 0 이상이어야 합니다.')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await _mealRecordService.updateMealRecord(
        recordId: recordId,
        date: _formatDate(selectedDate),
        mealType: selectedMealType,
        description: description,
        calories: calories,
        carbs: carbs,
        protein: protein,
        fat: fat,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('식단 기록이 수정되었습니다.')),
      );

      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('식단 기록 수정 실패: $e')),
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

    final dateText = _formatDate(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('식단 기록 수정'),
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
                          '식단 기록 수정',
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
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _updateMeal,
                    icon: const Icon(Icons.save),
                    label: Text(isLoading ? '수정 중...' : '수정 완료'),
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