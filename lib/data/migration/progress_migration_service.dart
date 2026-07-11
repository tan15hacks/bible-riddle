import 'dart:convert';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/player_progress.dart';
import '../repositories/drift_progress_repository.dart';
import '../repositories/shared_preferences_progress_repository.dart';

class ProgressMigrationService {
  ProgressMigrationService({
    required SharedPreferences preferences,
    required SharedPreferencesProgressRepository legacyRepository,
    required DriftProgressRepository driftRepository,
  })  : _preferences = preferences,
        _legacyRepository = legacyRepository,
        _driftRepository = driftRepository;

  static const _migrationFlag =
      'migration.progress.shared_preferences_to_drift.v1';

  final SharedPreferences _preferences;
  final SharedPreferencesProgressRepository _legacyRepository;
  final DriftProgressRepository _driftRepository;

  Future<void> migrateIfNeeded() async {
    if (_preferences.getBool(_migrationFlag) ?? false) return;

    final levelProgress = _preferences.containsKey('progress.levels.v1')
        ? await _legacyRepository.getAllLevelProgress()
        : _readPhaseALevelProgress();

    for (final progress in levelProgress.values) {
      await _driftRepository.saveLevelProgress(progress);
    }

    final economy = _preferences.containsKey('progress.economy.v1')
        ? await _legacyRepository.getEconomy()
        : _readPhaseAEconomy();
    await _driftRepository.saveEconomy(economy);

    final statistics = _preferences.containsKey('progress.statistics.v1')
        ? await _legacyRepository.getStatistics()
        : _readPhaseAStatistics();
    await _driftRepository.saveStatistics(statistics);

    await _preferences.setBool(_migrationFlag, true);
  }

  Map<String, LevelProgress> _readPhaseALevelProgress() {
    final raw = _preferences.getString('starsByRiddle');
    if (raw == null || raw.isEmpty) return <String, LevelProgress>{};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((riddleId, stars) {
        return MapEntry(
          riddleId,
          LevelProgress(
            riddleId: riddleId,
            completed: true,
            stars: stars as int? ?? 1,
            attempts: 0,
            wrongAttempts: 0,
            hintsUsed: 0,
          ),
        );
      });
    } on FormatException {
      return <String, LevelProgress>{};
    }
  }

  PlayerEconomy _readPhaseAEconomy() {
    final coins = _preferences.getInt('coins') ?? 120;
    return PlayerEconomy(
      coins: coins,
      totalCoinsEarned: math.max(120, coins),
      totalCoinsSpent: 0,
    );
  }

  PlayerStatistics _readPhaseAStatistics() {
    return PlayerStatistics(
      totalAnswers: _preferences.getInt('totalAnswers') ?? 0,
      correctAnswers: _preferences.getInt('correctAnswers') ?? 0,
      currentStreak: _preferences.getInt('currentStreak') ?? 0,
      bestStreak: _preferences.getInt('bestStreak') ?? 0,
      dailyStreak: 0,
      totalPlayTime: Duration.zero,
      challengeScoresJson: '{}',
    );
  }
}
