import '../../domain/entities/engagement.dart';
import '../../domain/entities/player_progress.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../domain/repositories/progress_repository.dart';

const achievementCatalog = <AchievementDefinition>[
  AchievementDefinition(
    id: 'first_step',
    title: 'First Step',
    description: 'Complete your first Bible riddle.',
    target: 1,
    iconKey: 'star',
    rewardCoins: 20,
  ),
  AchievementDefinition(
    id: 'five_levels',
    title: 'Faithful Learner',
    description: 'Complete 5 riddles.',
    target: 5,
    iconKey: 'book',
    rewardCoins: 30,
  ),
  AchievementDefinition(
    id: 'star_collector',
    title: 'Star Collector',
    description: 'Earn 15 total stars.',
    target: 15,
    iconKey: 'stars',
    rewardCoins: 35,
  ),
  AchievementDefinition(
    id: 'answer_scholar',
    title: 'Bible Scholar',
    description: 'Answer 10 riddles correctly.',
    target: 10,
    iconKey: 'school',
    rewardCoins: 40,
  ),
  AchievementDefinition(
    id: 'streak_keeper',
    title: 'Streak Keeper',
    description: 'Reach a best answer streak of 3.',
    target: 3,
    iconKey: 'local_fire',
    rewardCoins: 30,
  ),
  AchievementDefinition(
    id: 'coin_collector',
    title: 'Coin Collector',
    description: 'Earn 250 coins in total.',
    target: 250,
    iconKey: 'paid',
    rewardCoins: 50,
  ),
  AchievementDefinition(
    id: 'daily_reader',
    title: 'Daily Reader',
    description: 'Build a 3-day Daily Riddle streak.',
    target: 3,
    iconKey: 'calendar',
    rewardCoins: 50,
  ),
];

class AchievementSnapshot {
  const AchievementSnapshot({
    required this.completedLevels,
    required this.totalStars,
    required this.economy,
    required this.statistics,
  });

  final int completedLevels;
  final int totalStars;
  final PlayerEconomy economy;
  final PlayerStatistics statistics;
}

class AchievementService {
  AchievementService({
    required EngagementRepository engagementRepository,
    required ProgressRepository progressRepository,
  })  : _engagementRepository = engagementRepository,
        _progressRepository = progressRepository;

  final EngagementRepository _engagementRepository;
  final ProgressRepository _progressRepository;

  Future<AchievementEvaluationResult> evaluate(
    AchievementSnapshot snapshot,
  ) async {
    final stored = await _engagementRepository.getAllAchievements();
    final states = <AchievementState>[];
    final newlyUnlocked = <AchievementDefinition>[];
    var rewardCoins = 0;
    final now = DateTime.now();

    for (final definition in achievementCatalog) {
      final previous = stored[definition.id];
      final rawProgress = _progressFor(definition.id, snapshot);
      final progress = rawProgress > definition.target
          ? definition.target
          : rawProgress;
      final unlocked = previous?.unlocked == true ||
          progress >= definition.target;
      final becameUnlocked = previous?.unlocked != true && unlocked;
      final record = AchievementRecord(
        achievementId: definition.id,
        unlocked: unlocked,
        unlockedAt: previous?.unlockedAt ?? (becameUnlocked ? now : null),
        progress: progress,
        target: definition.target,
      );

      await _engagementRepository.saveAchievement(record);
      states.add(AchievementState(definition: definition, record: record));
      if (becameUnlocked) {
        newlyUnlocked.add(definition);
        rewardCoins += definition.rewardCoins;
      }
    }

    if (rewardCoins > 0) {
      final economy = await _progressRepository.getEconomy();
      await _progressRepository.saveEconomy(
        PlayerEconomy(
          coins: economy.coins + rewardCoins,
          totalCoinsEarned: economy.totalCoinsEarned + rewardCoins,
          totalCoinsSpent: economy.totalCoinsSpent,
        ),
      );
    }

    return AchievementEvaluationResult(
      states: List.unmodifiable(states),
      newlyUnlocked: List.unmodifiable(newlyUnlocked),
      coinsAwarded: rewardCoins,
    );
  }

  int _progressFor(String achievementId, AchievementSnapshot snapshot) {
    return switch (achievementId) {
      'first_step' || 'five_levels' => snapshot.completedLevels,
      'star_collector' => snapshot.totalStars,
      'answer_scholar' => snapshot.statistics.correctAnswers,
      'streak_keeper' => snapshot.statistics.bestStreak,
      'coin_collector' => snapshot.economy.totalCoinsEarned,
      'daily_reader' => snapshot.statistics.dailyStreak,
      _ => 0,
    };
  }
}
