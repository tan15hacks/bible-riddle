import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../domain/entities/player_progress.dart';
import '../../domain/repositories/progress_repository.dart';

class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._database);

  final AppDatabase _database;

  @override
  Future<LevelProgress?> getLevelProgress(String riddleId) async {
    final row = await (_database.select(_database.levelProgressRows)
          ..where((table) => table.riddleId.equals(riddleId)))
        .getSingleOrNull();
    return row == null ? null : _toLevelProgress(row);
  }

  @override
  Future<Map<String, LevelProgress>> getAllLevelProgress() async {
    final rows = await _database.select(_database.levelProgressRows).get();
    return Map.unmodifiable({
      for (final row in rows) row.riddleId: _toLevelProgress(row),
    });
  }

  @override
  Future<void> saveLevelProgress(LevelProgress progress) async {
    final existing = await getLevelProgress(progress.riddleId);
    final merged = _mergeBest(existing, progress);
    await _database.into(_database.levelProgressRows).insertOnConflictUpdate(
          LevelProgressRowsCompanion(
            riddleId: Value(merged.riddleId),
            completed: Value(merged.completed),
            stars: Value(merged.stars),
            attempts: Value(merged.attempts),
            wrongAttempts: Value(merged.wrongAttempts),
            hintsUsed: Value(merged.hintsUsed),
            firstCompletedAt: Value(merged.firstCompletedAt),
            lastPlayedAt: Value(merged.lastPlayedAt),
            bestCompletionTimeMs: Value(
              merged.bestCompletionTime?.inMilliseconds,
            ),
          ),
        );
  }

  @override
  Future<PlayerEconomy> getEconomy() async {
    final row = await (_database.select(_database.playerEconomyRows)
          ..where((table) => table.id.equals(1)))
        .getSingleOrNull();
    if (row == null) {
      return const PlayerEconomy(
        coins: 120,
        totalCoinsEarned: 120,
        totalCoinsSpent: 0,
      );
    }
    return PlayerEconomy(
      coins: row.coins,
      totalCoinsEarned: row.totalCoinsEarned,
      totalCoinsSpent: row.totalCoinsSpent,
    );
  }

  @override
  Future<void> saveEconomy(PlayerEconomy economy) async {
    await _database.into(_database.playerEconomyRows).insertOnConflictUpdate(
          PlayerEconomyRowsCompanion(
            id: const Value(1),
            coins: Value(economy.coins),
            totalCoinsEarned: Value(economy.totalCoinsEarned),
            totalCoinsSpent: Value(economy.totalCoinsSpent),
          ),
        );
  }

  @override
  Future<PlayerStatistics> getStatistics() async {
    final row = await (_database.select(_database.playerStatisticsRows)
          ..where((table) => table.id.equals(1)))
        .getSingleOrNull();
    if (row == null) {
      return const PlayerStatistics(
        totalAnswers: 0,
        correctAnswers: 0,
        currentStreak: 0,
        bestStreak: 0,
        dailyStreak: 0,
        totalPlayTime: Duration.zero,
        challengeScoresJson: '{}',
      );
    }
    return PlayerStatistics(
      totalAnswers: row.totalAnswers,
      correctAnswers: row.correctAnswers,
      currentStreak: row.currentStreak,
      bestStreak: row.bestStreak,
      dailyStreak: row.dailyStreak,
      totalPlayTime: Duration(seconds: row.totalPlayTimeSeconds),
      challengeScoresJson: row.challengeScoresJson,
    );
  }

  @override
  Future<void> saveStatistics(PlayerStatistics statistics) async {
    await _database
        .into(_database.playerStatisticsRows)
        .insertOnConflictUpdate(
          PlayerStatisticsRowsCompanion(
            id: const Value(1),
            totalAnswers: Value(statistics.totalAnswers),
            correctAnswers: Value(statistics.correctAnswers),
            currentStreak: Value(statistics.currentStreak),
            bestStreak: Value(statistics.bestStreak),
            dailyStreak: Value(statistics.dailyStreak),
            totalPlayTimeSeconds: Value(statistics.totalPlayTime.inSeconds),
            challengeScoresJson: Value(statistics.challengeScoresJson),
          ),
        );
  }

  @override
  Future<void> resetAllProgress() async {
    await _database.transaction(() async {
      await _database.delete(_database.levelProgressRows).go();
      await _database.delete(_database.playerEconomyRows).go();
      await _database.delete(_database.playerStatisticsRows).go();
    });
  }

  LevelProgress _toLevelProgress(LevelProgressRow row) {
    return LevelProgress(
      riddleId: row.riddleId,
      completed: row.completed,
      stars: row.stars,
      attempts: row.attempts,
      wrongAttempts: row.wrongAttempts,
      hintsUsed: row.hintsUsed,
      firstCompletedAt: row.firstCompletedAt,
      lastPlayedAt: row.lastPlayedAt,
      bestCompletionTime: row.bestCompletionTimeMs == null
          ? null
          : Duration(milliseconds: row.bestCompletionTimeMs!),
    );
  }

  LevelProgress _mergeBest(
    LevelProgress? existing,
    LevelProgress incoming,
  ) {
    if (existing == null) return incoming;
    return LevelProgress(
      riddleId: incoming.riddleId,
      completed: existing.completed || incoming.completed,
      stars: incoming.stars > existing.stars
          ? incoming.stars
          : existing.stars,
      attempts: incoming.attempts,
      wrongAttempts: incoming.wrongAttempts,
      hintsUsed: incoming.hintsUsed,
      firstCompletedAt: existing.firstCompletedAt ?? incoming.firstCompletedAt,
      lastPlayedAt: incoming.lastPlayedAt ?? DateTime.now(),
      bestCompletionTime: _bestDuration(
        existing.bestCompletionTime,
        incoming.bestCompletionTime,
      ),
    );
  }

  Duration? _bestDuration(Duration? first, Duration? second) {
    if (first == null) return second;
    if (second == null) return first;
    return first <= second ? first : second;
  }
}
