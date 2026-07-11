import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../data/database/content_database_seeder.dart';
import '../../data/migration/progress_migration_service.dart';
import '../../data/repositories/asset_content_repository.dart';
import '../../data/repositories/drift_progress_repository.dart';
import '../../data/repositories/shared_preferences_progress_repository.dart';
import '../../domain/entities/riddle.dart';
import '../../domain/repositories/progress_repository.dart';
import '../gameplay/gameplay_runtime.dart';

class RuntimeDependencies {
  RuntimeDependencies({
    required this.preferences,
    required this.riddles,
    required this.progressRepository,
    required this.gameplayRuntime,
    required this.usingDrift,
    this.database,
  });

  final SharedPreferences preferences;
  final List<Riddle> riddles;
  final ProgressRepository progressRepository;
  final GameplayRuntime gameplayRuntime;
  final bool usingDrift;
  final AppDatabase? database;

  Future<void> dispose() async {
    await database?.close();
  }
}

class RuntimeBootstrap {
  static Future<RuntimeDependencies> create() async {
    final preferences = await SharedPreferences.getInstance();
    final contentRepository = AssetContentRepository();
    final riddles = await contentRepository.getRiddles();
    final legacyRepository =
        SharedPreferencesProgressRepository(preferences);

    AppDatabase? database;
    try {
      database = await AppDatabase.open();
      await ContentDatabaseSeeder(database).seedRiddles(riddles);

      final driftRepository = DriftProgressRepository(database);
      await ProgressMigrationService(
        preferences: preferences,
        legacyRepository: legacyRepository,
        driftRepository: driftRepository,
      ).migrateIfNeeded();

      return RuntimeDependencies(
        preferences: preferences,
        riddles: riddles,
        progressRepository: driftRepository,
        gameplayRuntime: GameplayRuntime(driftRepository),
        usingDrift: true,
        database: database,
      );
    } catch (_) {
      await database?.close();
      return RuntimeDependencies(
        preferences: preferences,
        riddles: riddles,
        progressRepository: legacyRepository,
        gameplayRuntime: GameplayRuntime(legacyRepository),
        usingDrift: false,
      );
    }
  }
}
