class LevelProgress {
  const LevelProgress({
    required this.riddleId,
    required this.completed,
    required this.stars,
    required this.attempts,
    required this.wrongAttempts,
    required this.hintsUsed,
    this.firstCompletedAt,
    this.lastPlayedAt,
    this.bestCompletionTime,
  });

  final String riddleId;
  final bool completed;
  final int stars;
  final int attempts;
  final int wrongAttempts;
  final int hintsUsed;
  final DateTime? firstCompletedAt;
  final DateTime? lastPlayedAt;
  final Duration? bestCompletionTime;
}

class PlayerEconomy {
  const PlayerEconomy({
    required this.coins,
    required this.totalCoinsEarned,
    required this.totalCoinsSpent,
  });

  final int coins;
  final int totalCoinsEarned;
  final int totalCoinsSpent;
}

class PlayerStatistics {
  const PlayerStatistics({
    required this.totalAnswers,
    required this.correctAnswers,
    required this.currentStreak,
    required this.bestStreak,
    required this.dailyStreak,
    required this.totalPlayTime,
    required this.challengeScoresJson,
  });

  final int totalAnswers;
  final int correctAnswers;
  final int currentStreak;
  final int bestStreak;
  final int dailyStreak;
  final Duration totalPlayTime;
  final String challengeScoresJson;
}
