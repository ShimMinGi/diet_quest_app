import 'package:flutter/material.dart';

class DailyRecordDetailPage extends StatelessWidget {
  final Map<String, dynamic> record;

  const DailyRecordDetailPage({
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
    final weight = record['weight'];
    final calories = record['calories'];
    final waist = record['waist'];
    final arm = record['arm'];
    final thigh = record['thigh'];
    final isPeriod = record['isPeriod'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('일일 기록 상세'),
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
            label: '체중',
            value: _displayValue(weight, suffix: ' kg'),
            icon: Icons.monitor_weight,
          ),
          _buildDetailCard(
            label: '총 섭취 칼로리',
            value: _displayValue(calories, suffix: ' kcal'),
            icon: Icons.local_fire_department,
          ),
          _buildDetailCard(
            label: '허리 둘레',
            value: _displayValue(waist),
            icon: Icons.straighten,
          ),
          _buildDetailCard(
            label: '팔 둘레',
            value: _displayValue(arm),
            icon: Icons.fitness_center,
          ),
          _buildDetailCard(
            label: '허벅지 둘레',
            value: _displayValue(thigh),
            icon: Icons.directions_walk,
          ),
          _buildDetailCard(
            label: '생리 여부',
            value: isPeriod ? '예' : '아니오',
            icon: Icons.favorite,
          ),
        ],
      ),
    );
  }
}