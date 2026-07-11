import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/engagement.dart';
import '../../domain/repositories/engagement_repository.dart';

class SharedPreferencesEngagementRepository
    implements EngagementRepository {
  SharedPreferencesEngagementRepository(this._preferences);

  static const _achievementsKey = 'engagement.achievements.v1';
  static const _dailyRiddlesKey = 'engagement.daily_riddles.v1';

  final SharedPreferences _preferences;

  @override
  Future<Map<String, AchievementRecord>> getAllAchievements() async {
    final raw = _preferences.getString(_achievementsKey);
    if (raw == null) return const {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return Map.unmodifiable(
      decoded.map(
        (key, value) => MapEntry(
          key,
          _achievementFromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  @override
  Future<void> saveAchievement(AchievementRecord record) async {
    final all = Map<String, AchievementRecord>.from(
      await getAllAchievements(),
    );
    all[record.achievementId] = record;
    await _preferences.setString(
      _achievementsKey,
      jsonEncode(
        all.map(
          (key, value) => MapEntry(key, _achievementToJson(value)),
        ),
      ),
    );
  }

  @override
  Future<DailyRiddleRecord?> getDailyRiddle(String dateKey) async {
    return (await _readDailyRiddles())[dateKey];
  }

  @override
  Future<List<DailyRiddleRecord>> getAllDailyRiddles() async {
    return List.unmodifiable((await _readDailyRiddles()).values);
  }

  @override
  Future<void> saveDailyRiddle(DailyRiddleRecord record) async {
    final all = await _readDailyRiddles();
    all[record.dateKey] = record;
    await _preferences.setString(
      _dailyRiddlesKey,
      jsonEncode(
        all.map((key, value) => MapEntry(key, _dailyToJson(value))),
      ),
    );
  }

  @override
  Future<void> resetAllEngagement() async {
    await _preferences.remove(_achievementsKey);
    await _preferences.remove(_dailyRiddlesKey);
  }

  Future<Map<String, DailyRiddleRecord>> _readDailyRiddles() async {
    final raw = _preferences.getString(_dailyRiddlesKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        _dailyFromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Map<String, Object?> _achievementToJson(AchievementRecord record) => {
        'achievementId': record.achievementId,
        'unlocked': record.unlocked,
        'unlockedAt': record.unlockedAt?.toIso8601String(),
        'progress': record.progress,
        'target': record.target,
      };

  AchievementRecord _achievementFromJson(Map<String, dynamic> json) {
    return AchievementRecord(
      achievementId: json['achievementId'] as String,
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: _date(json['unlockedAt']),
      progress: json['progress'] as int? ?? 0,
      target: json['target'] as int? ?? 1,
    );
  }

  Map<String, Object?> _dailyToJson(DailyRiddleRecord record) => {
        'dateKey': record.dateKey,
        'riddleId': record.riddleId,
        'completed': record.completed,
        'stars': record.stars,
        'rewardClaimed': record.rewardClaimed,
      };

  DailyRiddleRecord _dailyFromJson(Map<String, dynamic> json) {
    return DailyRiddleRecord(
      dateKey: json['dateKey'] as String,
      riddleId: json['riddleId'] as String,
      completed: json['completed'] as bool? ?? false,
      stars: json['stars'] as int? ?? 0,
      rewardClaimed: json['rewardClaimed'] as bool? ?? false,
    );
  }

  DateTime? _date(Object? value) =>
      value == null ? null : DateTime.tryParse(value as String);
}
