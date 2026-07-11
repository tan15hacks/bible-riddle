import 'dart:convert';

import 'package:bible_riddle/core/database/app_database.dart'
    show AppDatabase;
import 'package:bible_riddle/data/database/content_database_seeder.dart';
import 'package:bible_riddle/data/migration/progress_migration_service.dart';
import 'package:bible_riddle/data/repositories/drift_progress_repository.dart';
import 'package:bible_riddle/data/repositories/shared_preferences_progress_repository.dart';
import 'package:bible_riddle/domain/entities/player_progress.dart';
import 'package:bible_riddle/domain/entities/riddle.dart';
import 'package:bible_riddle/domain/entities/testament.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppDatabase? database;

  tearDown(() async {
    await database?.close();
    database = null;
  });

  test('migrates the original Phase A save keys into Drift', () async {
    SharedPreferences.setMockInitialValues({
      'starsByRiddle': jsonEncode({'OT-EXO-003-001': 3}),
      'coins': 180,
      'totalAnswers': 7,
      'correctAnswers': 5,
      'currentStreak': 2,
      'bestStreak': 4,
    });
    final preferences = await SharedPreferences.getInstance();
    final activeDatabase = AppDatabase(NativeDatabase.memory());
    database = activeDatabase;
    await ContentDatabaseSeeder(activeDatabase).seedRiddles(
      const [sampleRiddle],
    );

    final driftRepository = DriftProgressRepository(activeDatabase);
    await ProgressMigrationService(
      preferences: preferences,
      legacyRepository: SharedPreferencesProgressRepository(preferences),
      driftRepository: driftRepository,
    ).migrateIfNeeded();

    expect(
      (await driftRepository.getLevelProgress('OT-EXO-003-001'))?.stars,
      3,
    );
    expect((await driftRepository.getEconomy()).coins, 180);
    expect((await driftRepository.getStatistics()).bestStreak, 4);
  });

  test('migration is idempotent after its completion flag is stored', () async {
    SharedPreferences.setMockInitialValues({
      'starsByRiddle': jsonEncode({'OT-EXO-003-001': 2}),
      'coins': 150,
    });
    final preferences = await SharedPreferences.getInstance();
    final activeDatabase = AppDatabase(NativeDatabase.memory());
    database = activeDatabase;
    await ContentDatabaseSeeder(activeDatabase).seedRiddles(
      const [sampleRiddle],
    );

    final driftRepository = DriftProgressRepository(activeDatabase);
    final migration = ProgressMigrationService(
      preferences: preferences,
      legacyRepository: SharedPreferencesProgressRepository(preferences),
      driftRepository: driftRepository,
    );

    await migration.migrateIfNeeded();
    await driftRepository.saveEconomy(
      const PlayerEconomy(
        coins: 222,
        totalCoinsEarned: 222,
        totalCoinsSpent: 0,
      ),
    );
    await migration.migrateIfNeeded();

    expect((await driftRepository.getEconomy()).coins, 222);
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
  conceptTags: ['Moses'],
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
