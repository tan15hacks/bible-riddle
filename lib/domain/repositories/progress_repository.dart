import '../entities/player_progress.dart';

abstract interface class ProgressRepository {
  Future<LevelProgress?> getLevelProgress(String riddleId);
  Future<Map<String, LevelProgress>> getAllLevelProgress();
  Future<void> saveLevelProgress(LevelProgress progress);
  Future<PlayerEconomy> getEconomy();
  Future<void> saveEconomy(PlayerEconomy economy);
  Future<PlayerStatistics> getStatistics();
  Future<void> saveStatistics(PlayerStatistics statistics);
  Future<void> resetAllProgress();
}
