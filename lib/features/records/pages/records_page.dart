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
    _loadRecords();
  }

  void _loadRecords() {
    _dailyRecordsFuture = _recordsService.getDailyRecords();
    _mealRecordsFuture = _recordsService.getMealRecords();
  }

  Future<void> _refreshRecords() async {
    setState(() {
      _loadRecords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

        return Column(
          children: [
            _buildSectionHeader(
              icon: Icons.calendar_month,
              title: '일일 기록',
              subtitle: '체중, 칼로리, 둘레 기록을 확인하세요',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshRecords,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final record = records[index];

                    final date = record['date']?.toString() ?? '-';
                    final weight = record['weight']?.toString() ?? '0';
                    final calories = record['calories']?.toString() ?? '0';
                    final isPeriod = record['isPeriod'] == true;

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DailyRecordDetailPage(record: record),
                            ),
                          );

                          if (updated == true) {
                            await _refreshRecords();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.edit_note,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            date,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (isPeriod)
                                          const Icon(
                                            Icons.favorite,
                                            color: Colors.pink,
                                            size: 18,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '체중: $weight kg',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '칼로리: $calories kcal',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
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

        return Column(
          children: [
            _buildSectionHeader(
              icon: Icons.restaurant_menu,
              title: '식단 기록',
              subtitle: '식사 종류와 영양 정보를 확인하세요',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshRecords,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final record = records[index];

                    final date = record['date']?.toString() ?? '-';
                    final mealType = record['mealType']?.toString() ?? '-';
                    final calories = record['calories']?.toString() ?? '0';
                    final description = record['description']?.toString() ?? '-';

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MealRecordDetailPage(record: record),
                            ),
                          );

                          if (updated == true) {
                            await _refreshRecords();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$date · $mealType',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '칼로리: $calories kcal',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기록 보기'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF2E7D32),
          indicatorWeight: 3,
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