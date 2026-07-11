import '../entities/player_progress.dart';

abstract interface class ProgressRepository {
  Future<LevelProgress?> getLevelProgress(String riddleId);
  Future<void> saveLevelProgress(LevelProgress progress);
  Future<PlayerEconomy> getEconomy();
  Future<void> saveEconomy(PlayerEconomy economy);
  Future<PlayerStatistics> getStatistics();
  Future<void> saveStatistics(PlayerStatistics statistics);
}
