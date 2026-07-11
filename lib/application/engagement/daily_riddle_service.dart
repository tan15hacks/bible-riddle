import '../../domain/entities/engagement.dart';
import '../../domain/entities/player_progress.dart';
import '../../domain/entities/riddle.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../domain/repositories/progress_repository.dart';

const dailyRiddleBonusCoins = 25;

class DailyRiddleService {
  DailyRiddleService({
    required EngagementRepository engagementRepository,
    required ProgressRepository progressRepository,
  })  : _engagementRepository = engagementRepository,
        _progressRepository = progressRepository;

  final EngagementRepository _engagementRepository;
  final ProgressRepository _progressRepository;

  Future<DailyRiddleRecord> ensureDailyRiddle({
    required List<Riddle> riddles,
    required DateTime date,
  }) async {
    if (riddles.isEmpty) {
      throw StateError('Daily Riddle requires at least one riddle.');
    }

    final key = dateKey(date);
    final existing = await _engagementRepository.getDailyRiddle(key);
    if (existing != null) return existing;

    final selected = selectRiddle(riddles: riddles, date: date);
    final record = DailyRiddleRecord(
      dateKey: key,
      riddleId: selected.id,
      completed: false,
      stars: 0,
      rewardClaimed: false,
    );
    await _engagementRepository.saveDailyRiddle(record);
    return record;
  }

  Riddle selectRiddle({
    required List<Riddle> riddles,
    required DateTime date,
  }) {
    if (riddles.isEmpty) {
      throw StateError('Daily Riddle requires at least one riddle.');
    }
    final day = DateTime.utc(date.year, date.month, date.day);
    final epoch = DateTime.utc(2020);
    final index = day.difference(epoch).inDays.abs() % riddles.length;
    return riddles[index];
  }

  Future<DailyCompletionResult> completeDailyRiddle({
    required String riddleId,
    required int stars,
    required DateTime date,
  }) async {
    final key = dateKey(date);
    final previous = await _engagementRepository.getDailyRiddle(key);
    if (previous?.rewardClaimed == true) {
      return DailyCompletionResult(
        coinsAwarded: 0,
        dailyStreak: await _calculateCurrentStreak(date),
        wasAlreadyCompleted: true,
      );
    }

    final bestStars = previous == null || stars > previous.stars
        ? stars
        : previous.stars;
    await _engagementRepository.saveDailyRiddle(
      DailyRiddleRecord(
        dateKey: key,
        riddleId: previous?.riddleId ?? riddleId,
        completed: true,
        stars: bestStars,
        rewardClaimed: true,
      ),
    );

    final economy = await _progressRepository.getEconomy();
    await _progressRepository.saveEconomy(
      PlayerEconomy(
        coins: economy.coins + dailyRiddleBonusCoins,
        totalCoinsEarned:
            economy.totalCoinsEarned + dailyRiddleBonusCoins,
        totalCoinsSpent: economy.totalCoinsSpent,
      ),
    );

    final dailyStreak = await _calculateCurrentStreak(date);
    final statistics = await _progressRepository.getStatistics();
    await _progressRepository.saveStatistics(
      PlayerStatistics(
        totalAnswers: statistics.totalAnswers,
        correctAnswers: statistics.correctAnswers,
        currentStreak: statistics.currentStreak,
        bestStreak: statistics.bestStreak,
        dailyStreak: dailyStreak,
        totalPlayTime: statistics.totalPlayTime,
        challengeScoresJson: statistics.challengeScoresJson,
      ),
    );

    return DailyCompletionResult(
      coinsAwarded: dailyRiddleBonusCoins,
      dailyStreak: dailyStreak,
      wasAlreadyCompleted: false,
    );
  }

  Future<int> _calculateCurrentStreak(DateTime date) async {
    final completedDates = (await _engagementRepository.getAllDailyRiddles())
        .where((record) => record.completed)
        .map((record) => record.dateKey)
        .toSet();

    var streak = 0;
    var cursor = DateTime.utc(date.year, date.month, date.day);
    while (completedDates.contains(dateKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  String dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
