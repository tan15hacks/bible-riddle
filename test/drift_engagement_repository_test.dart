import 'package:bible_riddle/core/database/app_database.dart'
    show AppDatabase;
import 'package:bible_riddle/data/database/content_database_seeder.dart';
import 'package:bible_riddle/data/repositories/drift_engagement_repository.dart';
import 'package:bible_riddle/domain/entities/engagement.dart';
import 'package:bible_riddle/domain/entities/riddle.dart';
import 'package:bible_riddle/domain/entities/testament.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftEngagementRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftEngagementRepository(database);
    await ContentDatabaseSeeder(database).seedRiddles(const [sampleRiddle]);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists achievement progress', () async {
    await repository.saveAchievement(
      AchievementRecord(
        achievementId: 'first_step',
        unlocked: true,
        unlockedAt: DateTime(2026, 7, 11),
        progress: 1,
        target: 1,
      ),
    );

    final record =
        (await repository.getAllAchievements())['first_step'];
    expect(record?.unlocked, isTrue);
    expect(record?.progress, 1);
  });

  test('persists daily riddle completion and reset', () async {
    await repository.saveDailyRiddle(
      const DailyRiddleRecord(
        dateKey: '2026-07-11',
        riddleId: 'OT-001',
        completed: true,
        stars: 3,
        rewardClaimed: true,
      ),
    );

    final record = await repository.getDailyRiddle('2026-07-11');
    expect(record?.completed, isTrue);
    expect((await repository.getAllDailyRiddles()).length, 1);

    await repository.resetAllEngagement();
    expect(await repository.getAllDailyRiddles(), isEmpty);
    expect(await repository.getAllAchievements(), isEmpty);
  });
}

const sampleRiddle = Riddle(
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
);
