import 'package:flutter/material.dart';

class MealRecordDetailPage extends StatelessWidget {
  final Map<String, dynamic> record;

  const MealRecordDetailPage({
    super.key,
    required this.record,
  });

  Widget _buildDetailCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _displayValue(dynamic value, {String suffix = ''}) {
    if (value == null) return '-';
    return '$value$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final date = record['date']?.toString() ?? '-';
    final mealType = record['mealType']?.toString() ?? '-';
    final description = record['description']?.toString() ?? '-';
    final calories = record['calories'];
    final carbs = record['carbs'];
    final protein = record['protein'];
    final fat = record['fat'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('식단 기록 상세'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDetailCard(
            label: '날짜',
            value: date,
            icon: Icons.calendar_month,
          ),
          _buildDetailCard(
            label: '식사 종류',
            value: mealType,
            icon: Icons.restaurant_menu,
          ),
          _buildDetailCard(
            label: '식단 설명',
            value: description,
            icon: Icons.notes,
          ),
          _buildDetailCard(
            label: '칼로리',
            value: _displayValue(calories, suffix: ' kcal'),
            icon: Icons.local_fire_department,
          ),
          _buildDetailCard(
            label: '탄수화물',
            value: _displayValue(carbs, suffix: ' g'),
            icon: Icons.rice_bowl,
          ),
          _buildDetailCard(
            label: '단백질',
            value: _displayValue(protein, suffix: ' g'),
            icon: Icons.egg_alt,
          ),
          _buildDetailCard(
            label: '지방',
            value: _displayValue(fat, suffix: ' g'),
            icon: Icons.opacity,
          ),
        ],
      ),
    );
  }
}