import '../entities/engagement.dart';

abstract interface class EngagementRepository {
  Future<Map<String, AchievementRecord>> getAllAchievements();
  Future<void> saveAchievement(AchievementRecord record);
  Future<DailyRiddleRecord?> getDailyRiddle(String dateKey);
  Future<List<DailyRiddleRecord>> getAllDailyRiddles();
  Future<void> saveDailyRiddle(DailyRiddleRecord record);
  Future<void> resetAllEngagement();
}
