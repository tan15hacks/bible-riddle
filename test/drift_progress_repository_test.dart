import 'package:bible_riddle/core/database/app_database.dart'
    show AppDatabase;
import 'package:bible_riddle/data/database/content_database_seeder.dart';
import 'package:bible_riddle/data/repositories/drift_progress_repository.dart';
import 'package:bible_riddle/domain/entities/player_progress.dart';
import 'package:bible_riddle/domain/entities/riddle.dart';
import 'package:bible_riddle/domain/entities/testament.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftProgressRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftProgressRepository(database);
    await ContentDatabaseSeeder(database).seedRiddles(const [sampleRiddle]);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists level progress and preserves the best stars', () async {
    await repository.saveLevelProgress(
      const LevelProgress(
        riddleId: 'OT-EXO-003-001',
        completed: true,
        stars: 3,
        attempts: 1,
        wrongAttempts: 0,
        hintsUsed: 0,
      ),
    );
    await repository.saveLevelProgress(
      const LevelProgress(
        riddleId: 'OT-EXO-003-001',
        completed: true,
        stars: 1,
        attempts: 3,
        wrongAttempts: 2,
        hintsUsed: 1,
      ),
    );

    final progress = await repository.getLevelProgress('OT-EXO-003-001');
    expect(progress?.completed, isTrue);
    expect(progress?.stars, 3);
    expect((await repository.getAllLevelProgress()).length, 1);
  });

  test('persists economy and statistics', () async {
    await repository.saveEconomy(
      const PlayerEconomy(
        coins: 250,
        totalCoinsEarned: 300,
        totalCoinsSpent: 50,
      ),
    );
    await repository.saveStatistics(
      const PlayerStatistics(
        totalAnswers: 12,
        correctAnswers: 9,
        currentStreak: 2,
        bestStreak: 5,
        dailyStreak: 3,
        totalPlayTime: Duration(minutes: 8),
        challengeScoresJson: '{}',
      ),
    );

    expect((await repository.getEconomy()).coins, 250);
    expect((await repository.getStatistics()).bestStreak, 5);
  });

  test('reset clears progress and restores default reads', () async {
    await repository.saveLevelProgress(
      const LevelProgress(
        riddleId: 'OT-EXO-003-001',
        completed: true,
        stars: 2,
        attempts: 2,
        wrongAttempts: 1,
        hintsUsed: 0,
      ),
    );
    await repository.saveEconomy(
      const PlayerEconomy(
        coins: 10,
        totalCoinsEarned: 120,
        totalCoinsSpent: 110,
      ),
    );

    await repository.resetAllProgress();

    expect(await repository.getAllLevelProgress(), isEmpty);
    expect((await repository.getEconomy()).coins, 120);
    expect((await repository.getStatistics()).totalAnswers, 0);
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
  sectionId: 'ot-exodus',
  topic: 'Burning bush',
  storyEventId: 'moses-burning-bush-call',
  conceptTags: ['Moses', 'burning bush'],
  questionType: 'multiple_choice',
  difficulty: 2,
  question: 'Who heard a calling from the burning bush?',
  answer: 'Moses',
  acceptedAnswers: ['Moses'],
  choices: ['Moses', 'Aaron'],
  hints: ['He later led Israel from Egypt.'],
  explanation: 'Moses received his calling at the burning bush.',
  reference: 'Exodus 3:1-12',
  translationNotice: '',
  contentStatus: 'needs_review',
  sortOrder: 1,
  version: 1,
);
