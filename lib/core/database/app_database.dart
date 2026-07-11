import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Riddles extends Table {
  TextColumn get id => text()();
  TextColumn get testament => text()();
  TextColumn get book => text()();
  IntColumn get chapterStart => integer().nullable()();
  IntColumn get chapterEnd => integer().nullable()();
  IntColumn get verseStart => integer().nullable()();
  IntColumn get verseEnd => integer().nullable()();
  TextColumn get sectionId => text()();
  TextColumn get topic => text()();
  TextColumn get storyEventId => text()();
  TextColumn get questionType => text()();
  IntColumn get difficulty => integer()();
  TextColumn get question => text()();
  TextColumn get answer => text()();
  TextColumn get acceptedAnswersJson => text()();
  TextColumn get choicesJson => text()();
  TextColumn get hintsJson => text()();
  TextColumn get explanation => text()();
  TextColumn get reference => text()();
  TextColumn get conceptTagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get translationNotice => text().nullable()();
  TextColumn get contentStatus => text()();
  IntColumn get sortOrder => integer()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CampaignSections extends Table {
  TextColumn get id => text()();
  TextColumn get testament => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get booksJson => text().withDefault(const Constant('[]'))();
  IntColumn get orderIndex => integer()();
  IntColumn get requiredLevels => integer().withDefault(const Constant(0))();
  TextColumn get iconKey => text().withDefault(const Constant('scroll'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LevelProgress extends Table {
  TextColumn get riddleId => text().references(Riddles, #id)();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get stars => integer().withDefault(const Constant(0))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get wrongAttempts => integer().withDefault(const Constant(0))();
  IntColumn get hintsUsed => integer().withDefault(const Constant(0))();
  DateTimeColumn get firstCompletedAt => dateTime().nullable()();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  IntColumn get bestCompletionTimeMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {riddleId};
}

class PlayerProfileRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().withDefault(const Constant('Player'))();
  TextColumn get avatarKey => text().withDefault(const Constant('scroll'))();
  TextColumn get titleKey => text().withDefault(const Constant('listener'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PlayerEconomyRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get coins => integer().withDefault(const Constant(120))();
  IntColumn get totalCoinsEarned => integer().withDefault(const Constant(0))();
  IntColumn get totalCoinsSpent => integer().withDefault(const Constant(0))();
}

class PlayerStatisticsRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get totalAnswers => integer().withDefault(const Constant(0))();
  IntColumn get correctAnswers => integer().withDefault(const Constant(0))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  IntColumn get dailyStreak => integer().withDefault(const Constant(0))();
  IntColumn get totalPlayTimeMs => integer().withDefault(const Constant(0))();
  TextColumn get challengeScoresJson => text().withDefault(const Constant('{}'))();
}

class Achievements extends Table {
  TextColumn get achievementId => text()();
  BoolColumn get unlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  IntColumn get target => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {achievementId};
}

class DailyRiddleProgressRows extends Table {
  TextColumn get date => text()();
  TextColumn get riddleId => text().references(Riddles, #id)();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get stars => integer().withDefault(const Constant(0))();
  BoolColumn get rewardClaimed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {date};
}

class Purchases extends Table {
  TextColumn get productId => text()();
  TextColumn get entitlement => text()();
  TextColumn get purchaseStatus => text()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {productId};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Riddles,
    CampaignSections,
    LevelProgress,
    PlayerProfileRows,
    PlayerEconomyRows,
    PlayerStatisticsRows,
    Achievements,
    DailyRiddleProgressRows,
    Purchases,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(playerEconomyRows).insert(const PlayerEconomyRowsCompanion());
          await into(playerStatisticsRows).insert(const PlayerStatisticsRowsCompanion());
          await into(playerProfileRows).insert(const PlayerProfileRowsCompanion());
        },
        onUpgrade: (m, from, to) async {
          // Future migrations must preserve player progress and riddle IDs.
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bible_riddle.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
