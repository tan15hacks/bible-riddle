import 'package:bible_riddle/application/gameplay/gameplay_runtime.dart';
import 'package:bible_riddle/domain/entities/player_progress.dart';
import 'package:bible_riddle/domain/entities/riddle.dart';
import 'package:bible_riddle/domain/entities/testament.dart';
import 'package:bible_riddle/domain/repositories/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('repository-backed runtime awards progress, coins, and streaks', () async {
    final repo = MemoryProgressRepository();
    final runtime = GameplayRuntime(repo);
    final result = await runtime.submitAnswer(
      riddle: sampleRiddle,
      answer: 'Moses',
      attempts: 1,
      hintsUsed: 0,
    );

    expect(result.correct, isTrue);
    expect(result.stars, 3);
    expect(result.coinsAwarded, 15);
    expect((await repo.getLevelProgress(sampleRiddle.id))?.completed, isTrue);
    expect((await repo.getEconomy()).coins, 135);
    expect((await repo.getStatistics()).currentStreak, 1);
  });

  test('repository-backed runtime reports very close typed answers', () async {
    final runtime = GameplayRuntime(MemoryProgressRepository());
    final result = await runtime.submitAnswer(
      riddle: sampleRiddle,
      answer: 'Mose',
      attempts: 1,
      hintsUsed: 0,
    );

    expect(result.correct, isFalse);
    expect(result.veryClose, isTrue);
  });

  test('spendHint refuses when player lacks coins', () async {
    final repo = MemoryProgressRepository(
      economy: const PlayerEconomy(
        coins: 10,
        totalCoinsEarned: 10,
        totalCoinsSpent: 0,
      ),
    );
    final runtime = GameplayRuntime(repo);

    final result = await runtime.spendHint();

    expect(result.success, isFalse);
    expect((await repo.getEconomy()).coins, 10);
  });
}

const sampleRiddle = Riddle(
  id: 'OT-EXO-003-001',
  testament: Testament.old,
  book: 'Exodus',
  chapterStart: 3,
  chapterEnd: 3,
  verseStart: 1,
  verseEnd: 12,
  sectionId: 'moses-exodus',
  topic: 'Moses and the burning bush',
  storyEventId: 'moses-burning-bush',
  conceptTags: ['Moses', 'burning bush'],
  questionType: 'character_riddle',
  difficulty: 3,
  question: 'I heard God speak from a bush that burned but was not consumed. Who am I?',
  answer: 'Moses',
  acceptedAnswers: ['Moses'],
  choices: ['Moses', 'Aaron', 'Joshua', 'Caleb'],
  hints: ['I led Israel from Egypt.'],
  explanation: 'Moses encountered God at the burning bush.',
  reference: 'Exodus 3:1-12',
  translationNotice: '',
  contentStatus: 'needs_review',
  sortOrder: 1,
  version: 1,
);

class MemoryProgressRepository implements ProgressRepository {
  MemoryProgressRepository({PlayerEconomy? economy})
      : _economy = economy ??
            const PlayerEconomy(
              coins: 120,
              totalCoinsEarned: 120,
              totalCoinsSpent: 0,
            );

  final Map<String, LevelProgress> progress = {};
  PlayerEconomy _economy;
  PlayerStatistics _statistics = const PlayerStatistics(
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
      progress[riddleId];

  @override
  Future<Map<String, LevelProgress>> getAllLevelProgress() async =>
      Map.unmodifiable(progress);

  @override
  Future<void> saveLevelProgress(LevelProgress progress) async {
    this.progress[progress.riddleId] = progress;
  }

  @override
  Future<PlayerEconomy> getEconomy() async => _economy;

  @override
  Future<void> saveEconomy(PlayerEconomy economy) async {
    _economy = economy;
  }

  @override
  Future<PlayerStatistics> getStatistics() async => _statistics;

  @override
  Future<void> saveStatistics(PlayerStatistics statistics) async {
    _statistics = statistics;
  }

  @override
  Future<void> resetAllProgress() async {
    progress.clear();
    _economy = const PlayerEconomy(
      coins: 120,
      totalCoinsEarned: 120,
      totalCoinsSpent: 0,
    );
    _statistics = const PlayerStatistics(
      totalAnswers: 0,
      correctAnswers: 0,
      currentStreak: 0,
      bestStreak: 0,
      dailyStreak: 0,
      totalPlayTime: Duration.zero,
      challengeScoresJson: '{}',
    );
  }
}
