import 'package:flutter/material.dart';
import 'package:diet_quest_app/data/services/records_service.dart';
import 'package:diet_quest_app/features/records/pages/daily_record_detail_page.dart';
import 'package:diet_quest_app/features/records/pages/meal_record_detail_page.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage>
    with SingleTickerProviderStateMixin {
  final RecordsService _recordsService = RecordsService();

  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _dailyRecordsFuture;
  late Future<List<Map<String, dynamic>>> _mealRecordsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dailyRecordsFuture = _recordsService.getDailyRecords();
    _mealRecordsFuture = _recordsService.getMealRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildDailyRecordsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dailyRecordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('일일 기록 불러오기 실패: ${snapshot.error}'),
          );
        }

        final records = snapshot.data ?? [];

        if (records.isEmpty) {
          return const Center(
            child: Text(
              '저장된 일일 기록이 없습니다.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final record = records[index];

            final date = record['date']?.toString() ?? '-';
            final weight = record['weight']?.toString() ?? '0';
            final calories = record['calories']?.toString() ?? '0';

            return Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: Text(date),
                subtitle: Text('체중: $weight kg / 칼로리: $calories kcal'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DailyRecordDetailPage(record: record),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMealRecordsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _mealRecordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('식단 기록 불러오기 실패: ${snapshot.error}'),
          );
        }

        final records = snapshot.data ?? [];

        if (records.isEmpty) {
          return const Center(
            child: Text(
              '저장된 식단 기록이 없습니다.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final record = records[index];

            final date = record['date']?.toString() ?? '-';
            final mealType = record['mealType']?.toString() ?? '-';
            final calories = record['calories']?.toString() ?? '0';

            return Card(
              child: ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: Text('$date - $mealType'),
                subtitle: Text('칼로리: $calories kcal'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MealRecordDetailPage(record: record),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기록 보기'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '일일 기록'),
            Tab(text: '식단 기록'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyRecordsTab(),
          _buildMealRecordsTab(),
        ],
      ),
    );
  }
}