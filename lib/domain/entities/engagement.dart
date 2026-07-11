class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.iconKey,
  });

  final String id;
  final String title;
  final String description;
  final int target;
  final String iconKey;
}

class AchievementRecord {
  const AchievementRecord({
    required this.achievementId,
    required this.unlocked,
    required this.progress,
    required this.target,
    this.unlockedAt,
  });

  final String achievementId;
  final bool unlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int target;
}

class AchievementState {
  const AchievementState({
    required this.definition,
    required this.record,
  });

  final AchievementDefinition definition;
  final AchievementRecord record;

  double get completionRatio {
    if (record.target <= 0) return 0;
    return (record.progress / record.target).clamp(0, 1).toDouble();
  }
}

class DailyRiddleRecord {
  const DailyRiddleRecord({
    required this.dateKey,
    required this.riddleId,
    required this.completed,
    required this.stars,
    required this.rewardClaimed,
  });

  final String dateKey;
  final String riddleId;
  final bool completed;
  final int stars;
  final bool rewardClaimed;
}

class DailyCompletionResult {
  const DailyCompletionResult({
    required this.coinsAwarded,
    required this.dailyStreak,
    required this.wasAlreadyCompleted,
  });

  final int coinsAwarded;
  final int dailyStreak;
  final bool wasAlreadyCompleted;
}
