import 'package:flutter/material.dart';
import 'package:diet_quest_app/data/services/app_state.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  @override
  Widget build(BuildContext context) {
    final records = AppState.dailyRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('기록 보기'),
        centerTitle: true,
      ),
      body: records.isEmpty
          ? const Center(
              child: Text(
                '아직 저장된 기록이 없습니다.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = records[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(record.date),
                    subtitle: Text(
                      '체중: ${record.weight} kg / 칼로리: ${record.calories} kcal',
                    ),
                    trailing: record.isPeriod
                        ? const Icon(Icons.favorite, color: Colors.pink)
                        : null,
                  ),
                );
              },
            ),
    );
  }
}