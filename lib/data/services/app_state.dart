class DailyRecordItem {
  final String date;
  final double weight;
  final double calories;
  final double? waist;
  final double? arm;
  final double? thigh;
  final bool isPeriod;

  DailyRecordItem({
    required this.date,
    required this.weight,
    required this.calories,
    this.waist,
    this.arm,
    this.thigh,
    required this.isPeriod,
  });
}

class MealRecordItem {
  final String date;
  final String mealType;
  final String description;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;

  MealRecordItem({
    required this.date,
    required this.mealType,
    required this.description,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}

class AppState {
  static final List<DailyRecordItem> dailyRecords = [];
  static final List<MealRecordItem> mealRecords = [];
}