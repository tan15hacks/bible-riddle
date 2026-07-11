import 'package:bible_riddle/application/engagement/daily_riddle_service.dart';
import 'package:bible_riddle/domain/entities/engagement.dart';
import 'package:bible_riddle/domain/entities/player_progress.dart';
import 'package:bible_riddle/domain/entities/riddle.dart';
import 'package:bible_riddle/domain/entities/testament.dart';
import 'package:bible_riddle/domain/repositories/engagement_repository.dart';
import 'package:bible_riddle/domain/repositories/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selects the same riddle deterministically for a date', () {
    final service = DailyRiddleService(
      engagementRepository: MemoryEngagementRepository(),
      progressRepository: MemoryProgressRepository(),
    );
    final date = DateTime(2026, 7, 11);

    final first = service.selectRiddle(riddles: riddles, date: date);
    final second = service.selectRiddle(riddles: riddles, date: date);

    expect(first.id, second.id);
  });

  test('daily completion awards the bonus only once', () async {
    final engagement = MemoryEngagementRepository();
    final progress = MemoryProgressRepository();
    final service = DailyRiddleService(
      engagementRepository: engagement,
      progressRepository: progress,
    );
    final date = DateTime(2026, 7, 11);
    final record = await service.ensureDailyRiddle(
      riddles: riddles,
      date: date,
    );

    final first = await service.completeDailyRiddle(
      riddleId: record.riddleId,
      stars: 3,
      date: date,
    );
    final second = await service.completeDailyRiddle(
      riddleId: record.riddleId,
      stars: 3,
      date: date,
    );

    expect(first.coinsAwarded, dailyRiddleBonusCoins);
    expect(first.dailyStreak, 1);
    expect(second.coinsAwarded, 0);
    expect(second.wasAlreadyCompleted, isTrue);
    expect((await progress.getEconomy()).coins, 145);
  });

  test('consecutive completed days build the daily streak', () async {
    final engagement = MemoryEngagementRepository();
    final progress = MemoryProgressRepository();
    final service = DailyRiddleService(
      engagementRepository: engagement,
      progressRepository: progress,
    );

    for (final date in [
      DateTime(2026, 7, 9),
      DateTime(2026, 7, 10),
      DateTime(2026, 7, 11),
    ]) {
      final record = await service.ensureDailyRiddle(
        riddles: riddles,
        date: date,
      );
      await service.completeDailyRiddle(
        riddleId: record.riddleId,
        stars: 2,
        date: date,
      );
    }

    expect((await progress.getStatistics()).dailyStreak, 3);
  });
}

const riddles = [
  Riddle(
    id: 'OT-001',
    testament: Testament.old,
    book: 'Genesis',
    chapterStart: 1,
    chapterEnd: 1,
    verseStart: 1,
    verseEnd: 5,
    sectionId: 'ot-beginnings',
    topic: 'Creation',
    storyEventId: 'creation-light',
    conceptTags: ['creation'],
    questionType: 'multiple_choice',
    difficulty: 1,
    question: 'What was created to separate day from night?',
    answer: 'Light',
    acceptedAnswers: ['Light'],
    choices: ['Light', 'Land'],
    hints: ['It begins with L.'],
    explanation: 'Light was separated from darkness.',
    reference: 'Genesis 1:1-5',
    translationNotice: '',
    contentStatus: 'needs_review',
    sortOrder: 1,
    version: 1,
  ),
  Riddle(
    id: 'NT-001',
    testament: Testament.newTestament,
    book: 'Luke',
    chapterStart: 1,
    chapterEnd: 1,
    verseStart: 26,
    verseEnd: 38,
    sectionId: 'nt-birth',
    topic: 'Mary',
    storyEventId: 'gabriel-visits-mary',
    conceptTags: ['Mary'],
    questionType: 'typed_answer',
    difficulty: 1,
    question: 'Who received Gabriel’s announcement?',
    answer: 'Mary',
    acceptedAnswers: ['Mary'],
    choices: [],
    hints: ['Her name begins with M.'],
    explanation: 'Gabriel visited Mary.',
    reference: 'Luke 1:26-38',
    translationNotice: '',
    contentStatus: 'needs_review',
    sortOrder: 1,
    version: 1,
  ),
];

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
  final Map<String, LevelProgress> levels = {};
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
  Future<LevelProgress?> getLevelProgress(String riddleId) async =>
      levels[riddleId];

  @override
  Future<Map<String, LevelProgress>> getAllLevelProgress() async =>
      Map.unmodifiable(levels);

  @override
  Future<void> saveLevelProgress(LevelProgress progress) async {
    levels[progress.riddleId] = progress;
  }

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
  Future<void> resetAllProgress() async {
    levels.clear();
  }
}
