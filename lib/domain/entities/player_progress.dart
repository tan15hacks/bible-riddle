import 'dart:convert';

class LevelProgress {
  const LevelProgress({required this.stars, required this.attempts, required this.hintsUsed, required this.completedAt});

  final int stars;
  final int attempts;
  final int hintsUsed;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'stars': stars,
        'attempts': attempts,
        'hintsUsed': hintsUsed,
        'completedAt': completedAt.toIso8601String(),
      };
}

class PlayerProgress {
  const PlayerProgress({
    required this.coins,
    required this.totalAnswers,
    required this.correctAnswers,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalHintsUsed,
    required this.completions,
  });

  final int coins;
  final int totalAnswers;
  final int correctAnswers;
  final int currentStreak;
  final int bestStreak;
  final int totalHintsUsed;
  final Map<String, LevelProgress> completions;

  int get levelsCompleted => completions.length;
  int get starsEarned => completions.values.fold(0, (sum, item) => sum + item.stars);
  double get correctRate => totalAnswers == 0 ? 0 : correctAnswers / totalAnswers;

  bool isCompleted(String riddleId) => completions.containsKey(riddleId);
  int starsFor(String riddleId) => completions[riddleId]?.stars ?? 0;

  static PlayerProgress initial() => const PlayerProgress(
        coins: 120,
        totalAnswers: 0,
        correctAnswers: 0,
        currentStreak: 0,
        bestStreak: 0,
        totalHintsUsed: 0,
        completions: <String, LevelProgress>{},
      );

  String encode() => jsonEncode(<String, dynamic>{
        'coins': coins,
        'totalAnswers': totalAnswers,
        'correctAnswers': correctAnswers,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'totalHintsUsed': totalHintsUsed,
        'completions': completions.map((key, value) => MapEntry(key, value.toJson())),
      });
}
