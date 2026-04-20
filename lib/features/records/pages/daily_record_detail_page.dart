import 'package:flutter/material.dart';
import 'package:diet_quest_app/features/records/pages/edit_daily_record_page.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '일일 기록 상세',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailCard(
                    label: '체중',
                    value: _displayValue(weight, suffix: ' kg'),
                    icon: Icons.monitor_weight,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    label: '총 섭취 칼로리',
                    value: _displayValue(calories, suffix: ' kcal'),
                    icon: Icons.local_fire_department,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    label: '허리 둘레',
                    value: _displayValue(waist),
                    icon: Icons.straighten,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    label: '팔 둘레',
                    value: _displayValue(arm),
                    icon: Icons.fitness_center,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    label: '허벅지 둘레',
                    value: _displayValue(thigh),
                    icon: Icons.directions_walk,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    label: '생리 여부',
                    value: isPeriod ? '예' : '아니오',
                    icon: Icons.favorite,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditDailyRecordPage(record: record),
                        ),
                      );

                      if (updated == true && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('수정'),
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