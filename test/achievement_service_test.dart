import 'package:bible_riddle/application/engagement/achievement_service.dart';
import 'package:bible_riddle/domain/entities/engagement.dart';
import 'package:bible_riddle/domain/entities/player_progress.dart';
import 'package:bible_riddle/domain/repositories/engagement_repository.dart';
import 'package:bible_riddle/domain/repositories/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unlocks achievements and awards their coins only once', () async {
    final engagement = MemoryEngagementRepository();
    final progress = MemoryProgressRepository();
    final service = AchievementService(
      engagementRepository: engagement,
      progressRepository: progress,
    );
    const snapshot = AchievementSnapshot(
      completedLevels: 5,
      totalStars: 15,
      economy: PlayerEconomy(
        coins: 120,
        totalCoinsEarned: 250,
        totalCoinsSpent: 0,
      ),
      statistics: PlayerStatistics(
        totalAnswers: 10,
        correctAnswers: 10,
        currentStreak: 3,
        bestStreak: 3,
        dailyStreak: 3,
        totalPlayTime: Duration.zero,
        challengeScoresJson: '{}',
      ),
    );

    final first = await service.evaluate(snapshot);
    final coinsAfterFirst = (await progress.getEconomy()).coins;
    final second = await service.evaluate(snapshot);

    expect(first.newlyUnlocked.length, achievementCatalog.length);
    expect(first.coinsAwarded, greaterThan(0));
    expect(coinsAfterFirst, 120 + first.coinsAwarded);
    expect(second.newlyUnlocked, isEmpty);
    expect(second.coinsAwarded, 0);
    expect((await progress.getEconomy()).coins, coinsAfterFirst);
  });

  test('reports partial progress without unlocking', () async {
    final service = AchievementService(
      engagementRepository: MemoryEngagementRepository(),
      progressRepository: MemoryProgressRepository(),
    );
    const snapshot = AchievementSnapshot(
      completedLevels: 2,
      totalStars: 4,
      economy: PlayerEconomy(
        coins: 120,
        totalCoinsEarned: 120,
        totalCoinsSpent: 0,
      ),
      statistics: PlayerStatistics(
        totalAnswers: 2,
        correctAnswers: 2,
        currentStreak: 2,
        bestStreak: 2,
        dailyStreak: 0,
        totalPlayTime: Duration.zero,
        challengeScoresJson: '{}',
      ),
    );

    final result = await service.evaluate(snapshot);
    final fiveLevels = result.states.firstWhere(
      (state) => state.definition.id == 'five_levels',
    );

    expect(fiveLevels.record.progress, 2);
    expect(fiveLevels.record.unlocked, isFalse);
  });
}

class MemoryEngagementRepository implements EngagementRepository {
  final Map<String, AchievementRecord> achievements = {};
  final Map<String, DailyRiddleRecord> daily = {};

  @override
  Future<Map<String, AchievementRecord>> getAllAchievements() async =>
      Map.unmodifiable(achievements);

  @override
  Future<void> saveAchievement(AchievementRecord record) async {
    achievements[record.achievementId] = record;
  }

  @override
  Future<DailyRiddleRecord?> getDailyRiddle(String dateKey) async =>
      daily[dateKey];

  @override
  Future<List<DailyRiddleRecord>> getAllDailyRiddles() async =>
      List.unmodifiable(daily.values);

  @override
  Future<void> saveDailyRiddle(DailyRiddleRecord record) async {
    daily[record.dateKey] = record;
  }

  @override
  Future<void> resetAllEngagement() async {
    achievements.clear();
    daily.clear();
  }
}

class MemoryProgressRepository implements ProgressRepository {
  PlayerEconomy economy = const PlayerEconomy(
    coins: 120,
    totalCoinsEarned: 120,
    totalCoinsSpent: 0,
  );
  PlayerStatistics statistics = const PlayerStatistics(
    totalAnswers: 0,
    correctAnswers: 0,
    currentStreak: 0,
    bestStreak: 0,
    dailyStreak: 0,
    totalPlayTime: Duration.zero,
    challengeScoresJson: '{}',
  );

  @override
  Future<LevelProgress?> getLevelProgress(String riddleId) async => null;

  @override
  Future<Map<String, LevelProgress>> getAllLevelProgress() async => const {};

  @override
  Future<void> saveLevelProgress(LevelProgress progress) async {}

  @override
  Future<PlayerEconomy> getEconomy() async => economy;

  @override
  Future<void> saveEconomy(PlayerEconomy economy) async {
    this.economy = economy;
  }

  @override
  Future<PlayerStatistics> getStatistics() async => statistics;

  @override
  Future<void> saveStatistics(PlayerStatistics statistics) async {
    this.statistics = statistics;
  }

  @override
  Future<void> resetAllProgress() async {}
}
