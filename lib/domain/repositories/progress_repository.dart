import '../entities/player_progress.dart';

abstract interface class ProgressRepository {
  Future<PlayerProgress> loadProgress();
  Future<void> saveProgress(PlayerProgress progress);
  Future<void> resetProgress();
}
