import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/player_progress.dart';
import '../../domain/repositories/progress_repository.dart';

class SharedPreferencesProgressRepository implements ProgressRepository {
  SharedPreferencesProgressRepository(this._prefs);

  static const _levelProgressKey = 'progress.levels.v1';
  static const _economyKey = 'progress.economy.v1';
  static const _statisticsKey = 'progress.statistics.v1';

  final SharedPreferences _prefs;

  @override
  Future<LevelProgress?> getLevelProgress(String riddleId) async {
    return _readLevelProgress()[riddleId];
  }

  Future<Map<String, LevelProgress>> getAllLevelProgress() async {
    return Map.unmodifiable(_readLevelProgress());
  }

  @override
  Future<void> saveLevelProgress(LevelProgress progress) async {
    final all = _readLevelProgress();
    final existing = all[progress.riddleId];
    all[progress.riddleId] = _mergeBest(existing, progress);
    await _prefs.setString(_levelProgressKey, jsonEncode(all.map((key, value) => MapEntry(key, _levelProgressToJson(value)))));
  }

  @override
  Future<PlayerEconomy> getEconomy() async {
    final raw = _prefs.getString(_economyKey);
    if (raw == null) {
      return const PlayerEconomy(coins: 120, totalCoinsEarned: 120, totalCoinsSpent: 0);
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return PlayerEconomy(
      coins: json['coins'] as int? ?? 120,
      totalCoinsEarned: json['totalCoinsEarned'] as int? ?? 0,
      totalCoinsSpent: json['totalCoinsSpent'] as int? ?? 0,
    );
  }

  @override
  Future<void> saveEconomy(PlayerEconomy economy) async {
    await _prefs.setString(_economyKey, jsonEncode({
      'coins': economy.coins,
      'totalCoinsEarned': economy.totalCoinsEarned,
      'totalCoinsSpent': economy.totalCoinsSpent,
    }));
  }

  @override
  Future<PlayerStatistics> getStatistics() async {
    final raw = _prefs.getString(_statisticsKey);
    if (raw == null) {
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
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return PlayerStatistics(
      totalAnswers: json['totalAnswers'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      totalPlayTime: Duration(seconds: json['totalPlayTimeSeconds'] as int? ?? 0),
      challengeScoresJson: json['challengeScoresJson'] as String? ?? '{}',
    );
  }

  @override
  Future<void> saveStatistics(PlayerStatistics statistics) async {
    await _prefs.setString(_statisticsKey, jsonEncode({
      'totalAnswers': statistics.totalAnswers,
      'correctAnswers': statistics.correctAnswers,
      'currentStreak': statistics.currentStreak,
      'bestStreak': statistics.bestStreak,
      'dailyStreak': statistics.dailyStreak,
      'totalPlayTimeSeconds': statistics.totalPlayTime.inSeconds,
      'challengeScoresJson': statistics.challengeScoresJson,
    }));
  }

  Future<void> resetAllProgress() async {
    await _prefs.remove(_levelProgressKey);
    await _prefs.remove(_economyKey);
    await _prefs.remove(_statisticsKey);
  }

  Map<String, LevelProgress> _readLevelProgress() {
    final raw = _prefs.getString(_levelProgressKey);
    if (raw == null) return <String, LevelProgress>{};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, _levelProgressFromJson(value as Map<String, dynamic>)));
  }

  LevelProgress _mergeBest(LevelProgress? existing, LevelProgress incoming) {
    if (existing == null) return incoming;
    final bestStars = incoming.stars > existing.stars ? incoming.stars : existing.stars;
    return LevelProgress(
      riddleId: incoming.riddleId,
      completed: existing.completed || incoming.completed,
      stars: bestStars,
      attempts: incoming.attempts,
      wrongAttempts: incoming.wrongAttempts,
      hintsUsed: incoming.hintsUsed,
      firstCompletedAt: existing.firstCompletedAt ?? incoming.firstCompletedAt,
      lastPlayedAt: incoming.lastPlayedAt ?? DateTime.now(),
      bestCompletionTime: _bestDuration(existing.bestCompletionTime, incoming.bestCompletionTime),
    );
  }

  Duration? _bestDuration(Duration? a, Duration? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a <= b ? a : b;
  }

  Map<String, Object?> _levelProgressToJson(LevelProgress progress) => {
        'riddleId': progress.riddleId,
        'completed': progress.completed,
        'stars': progress.stars,
        'attempts': progress.attempts,
        'wrongAttempts': progress.wrongAttempts,
        'hintsUsed': progress.hintsUsed,
        'firstCompletedAt': progress.firstCompletedAt?.toIso8601String(),
        'lastPlayedAt': progress.lastPlayedAt?.toIso8601String(),
        'bestCompletionTimeMs': progress.bestCompletionTime?.inMilliseconds,
      };

  LevelProgress _levelProgressFromJson(Map<String, dynamic> json) {
    return LevelProgress(
      riddleId: json['riddleId'] as String,
      completed: json['completed'] as bool? ?? false,
      stars: json['stars'] as int? ?? 0,
      attempts: json['attempts'] as int? ?? 0,
      wrongAttempts: json['wrongAttempts'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      firstCompletedAt: _date(json['firstCompletedAt']),
      lastPlayedAt: _date(json['lastPlayedAt']),
      bestCompletionTime: json['bestCompletionTimeMs'] == null ? null : Duration(milliseconds: json['bestCompletionTimeMs'] as int),
    );
  }

  DateTime? _date(Object? value) => value == null ? null : DateTime.tryParse(value as String);
}
