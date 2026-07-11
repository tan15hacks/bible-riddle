import '../../domain/entities/player_progress.dart';
import '../../domain/entities/riddle.dart';
import '../../domain/repositories/progress_repository.dart';
import 'answer_matcher.dart';
import 'reward_rules.dart';

class GameplayRuntime {
  GameplayRuntime(this._progressRepository);

  final ProgressRepository _progressRepository;

  Future<AnswerResult> submitAnswer({
    required Riddle riddle,
    required String answer,
    required int attempts,
    required int hintsUsed,
    Duration? completionTime,
  }) async {
    final accepted = isAcceptedAnswer(answer, riddle.acceptedAnswers);
    if (!accepted) {
      return AnswerResult(
        correct: false,
        veryClose: isVeryCloseAnswer(answer, riddle.acceptedAnswers),
        stars: 0,
        coinsAwarded: 0,
      );
    }

    final existingProgress = await _progressRepository.getLevelProgress(riddle.id);
    final firstCompletion = existingProgress?.completed != true;
    final stars = calculateStars(attempts: attempts, hintsUsed: hintsUsed);
    final coins = calculateCoins(
      difficulty: riddle.difficulty,
      stars: stars,
      firstCompletion: firstCompletion,
    );
    final now = DateTime.now();

    await _progressRepository.saveLevelProgress(
      LevelProgress(
        riddleId: riddle.id,
        completed: true,
        stars: stars,
        attempts: attempts,
        wrongAttempts: attempts > 0 ? attempts - 1 : 0,
        hintsUsed: hintsUsed,
        firstCompletedAt: existingProgress?.firstCompletedAt ?? now,
        lastPlayedAt: now,
        bestCompletionTime: completionTime,
      ),
    );

    final economy = await _progressRepository.getEconomy();
    await _progressRepository.saveEconomy(
      PlayerEconomy(
        coins: economy.coins + coins,
        totalCoinsEarned: economy.totalCoinsEarned + coins,
        totalCoinsSpent: economy.totalCoinsSpent,
      ),
    );

    final statistics = await _progressRepository.getStatistics();
    final nextStreak = statistics.currentStreak + 1;
    await _progressRepository.saveStatistics(
      PlayerStatistics(
        totalAnswers: statistics.totalAnswers + 1,
        correctAnswers: statistics.correctAnswers + 1,
        currentStreak: nextStreak,
        bestStreak:
            nextStreak > statistics.bestStreak ? nextStreak : statistics.bestStreak,
        dailyStreak: statistics.dailyStreak,
        totalPlayTime: statistics.totalPlayTime,
        challengeScoresJson: statistics.challengeScoresJson,
      ),
    );

    return AnswerResult(
      correct: true,
      veryClose: false,
      stars: stars,
      coinsAwarded: coins,
    );
  }

  Future<HintSpendResult> spendHint() async {
    final economy = await _progressRepository.getEconomy();
    if (economy.coins < hintCoinCost) {
      return const HintSpendResult(success: false, remainingCoins: 0);
    }
    final next = PlayerEconomy(
      coins: economy.coins - hintCoinCost,
      totalCoinsEarned: economy.totalCoinsEarned,
      totalCoinsSpent: economy.totalCoinsSpent + hintCoinCost,
    );
    await _progressRepository.saveEconomy(next);
    return HintSpendResult(success: true, remainingCoins: next.coins);
  }

  Future<void> recordWrongAnswer() async {
    final statistics = await _progressRepository.getStatistics();
    await _progressRepository.saveStatistics(
      PlayerStatistics(
        totalAnswers: statistics.totalAnswers + 1,
        correctAnswers: statistics.correctAnswers,
        currentStreak: 0,
        bestStreak: statistics.bestStreak,
        dailyStreak: statistics.dailyStreak,
        totalPlayTime: statistics.totalPlayTime,
        challengeScoresJson: statistics.challengeScoresJson,
      ),
    );
  }
}

class AnswerResult {
  const AnswerResult({
    required this.correct,
    required this.veryClose,
    required this.stars,
    required this.coinsAwarded,
  });

  final bool correct;
  final bool veryClose;
  final int stars;
  final int coinsAwarded;
}

class HintSpendResult {
  const HintSpendResult({
    required this.success,
    required this.remainingCoins,
  });

  final bool success;
  final int remainingCoins;
}
