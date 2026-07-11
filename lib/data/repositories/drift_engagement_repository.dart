import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../domain/entities/engagement.dart';
import '../../domain/repositories/engagement_repository.dart';

class DriftEngagementRepository implements EngagementRepository {
  DriftEngagementRepository(this._database);

  final AppDatabase _database;

  @override
  Future<Map<String, AchievementRecord>> getAllAchievements() async {
    final rows = await _database.select(_database.achievementRows).get();
    return Map.unmodifiable({
      for (final row in rows)
        row.achievementId: AchievementRecord(
          achievementId: row.achievementId,
          unlocked: row.unlocked,
          unlockedAt: row.unlockedAt,
          progress: row.progress,
          target: row.target,
        ),
    });
  }

  @override
  Future<void> saveAchievement(AchievementRecord record) async {
    await _database.into(_database.achievementRows).insertOnConflictUpdate(
          AchievementRowsCompanion(
            achievementId: Value(record.achievementId),
            unlocked: Value(record.unlocked),
            unlockedAt: Value(record.unlockedAt),
            progress: Value(record.progress),
            target: Value(record.target),
          ),
        );
  }

  @override
  Future<DailyRiddleRecord?> getDailyRiddle(String dateKey) async {
    final row = await (_database.select(_database.dailyRiddleProgressRows)
          ..where((table) => table.date.equals(dateKey)))
        .getSingleOrNull();
    if (row == null) return null;
    return DailyRiddleRecord(
      dateKey: row.date,
      riddleId: row.riddleId,
      completed: row.completed,
      stars: row.stars,
      rewardClaimed: row.rewardClaimed,
    );
  }

  @override
  Future<List<DailyRiddleRecord>> getAllDailyRiddles() async {
    final rows = await _database.select(_database.dailyRiddleProgressRows).get();
    return List.unmodifiable(
      rows.map(
        (row) => DailyRiddleRecord(
          dateKey: row.date,
          riddleId: row.riddleId,
          completed: row.completed,
          stars: row.stars,
          rewardClaimed: row.rewardClaimed,
        ),
      ),
    );
  }

  @override
  Future<void> saveDailyRiddle(DailyRiddleRecord record) async {
    await _database
        .into(_database.dailyRiddleProgressRows)
        .insertOnConflictUpdate(
          DailyRiddleProgressRowsCompanion(
            date: Value(record.dateKey),
            riddleId: Value(record.riddleId),
            completed: Value(record.completed),
            stars: Value(record.stars),
            rewardClaimed: Value(record.rewardClaimed),
          ),
        );
  }

  @override
  Future<void> resetAllEngagement() async {
    await _database.transaction(() async {
      await _database.delete(_database.achievementRows).go();
      await _database.delete(_database.dailyRiddleProgressRows).go();
    });
  }
}
