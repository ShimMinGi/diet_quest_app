import 'game_rules.dart';

class StackResult {
  final int cherryStack;
  final int fireStack;
  final int penalty;

  const StackResult({
    required this.cherryStack,
    required this.fireStack,
    required this.penalty,
  });
}

class AchievementCalculator {
  static double calculateAchievementRate({
    required double startWeight,
    required double goalWeight,
    required double currentWeight,
  }) {
    final totalLoss = startWeight - goalWeight;
    final currentLoss = startWeight - currentWeight;

    if (totalLoss <= 0) return 0;

    return (currentLoss / totalLoss) * 100;
  }

  static StackResult calculateStackResult(double achievementRate) {
    if (achievementRate >= GameRules.fireThreshold) {
      return const StackResult(
        cherryStack: 0,
        fireStack: 1,
        penalty: 0,
      );
    }

    if (achievementRate >= GameRules.cherryThreshold) {
      return const StackResult(
        cherryStack: 1,
        fireStack: 0,
        penalty: 0,
      );
    }

    if (achievementRate < 0) {
      return const StackResult(
        cherryStack: 0,
        fireStack: 0,
        penalty: 1,
      );
    }

    return const StackResult(
      cherryStack: 0,
      fireStack: 0,
      penalty: 0,
    );
  }
}