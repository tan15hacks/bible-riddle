import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/bootstrap/runtime_bootstrap.dart';
import '../application/engagement/achievement_service.dart';
import '../application/engagement/daily_riddle_service.dart';
import '../application/gameplay/gameplay_runtime.dart';
import '../domain/entities/engagement.dart';
import '../domain/entities/riddle.dart';
import '../domain/entities/testament.dart';
import '../domain/repositories/engagement_repository.dart';
import '../domain/repositories/progress_repository.dart';

final gameProvider = ChangeNotifierProvider<GameState>(
  (ref) => GameState()..load(),
);

class SectionSummary {
  SectionSummary(this.id, this.title, this.testament, this.riddles);

  final String id;
  final String title;
  final Testament testament;
  final List<Riddle> riddles;
}

class GameState extends ChangeNotifier {
  RuntimeDependencies? _dependencies;
  ProgressRepository? _progressRepository;
  EngagementRepository? _engagementRepository;
  GameplayRuntime? _runtime;
  DailyRiddleService? _dailyRiddleService;
  AchievementService? _achievementService;

  bool loaded = false;
  bool onboarded = false;
  bool usingDrift = false;
  int coins = 120;
  int totalAnswers = 0;
  int correctAnswers = 0;
  int currentStreak = 0;
  int bestStreak = 0;
  int dailyStreak = 0;
  final Map<String, int> starsByRiddle = {};
  final List<Riddle> riddles = [];
  List<AchievementState> achievements = const [];
  DailyRiddleRecord? dailyRecord;
  Riddle? dailyRiddle;

  int get achievementUnlockedCount =>
      achievements.where((state) => state.record.unlocked).length;

  bool get dailyCompleted => dailyRecord?.completed ?? false;

  Future<void> load() async {
    final dependencies = await RuntimeBootstrap.create();
    _dependencies = dependencies;
    _progressRepository = dependencies.progressRepository;
    _engagementRepository = dependencies.engagementRepository;
    _runtime = dependencies.gameplayRuntime;
    _dailyRiddleService = DailyRiddleService(
      engagementRepository: dependencies.engagementRepository,
      progressRepository: dependencies.progressRepository,
    );
    _achievementService = AchievementService(
      engagementRepository: dependencies.engagementRepository,
      progressRepository: dependencies.progressRepository,
    );

    onboarded = dependencies.preferences.getBool('onboarded') ?? false;
    usingDrift = dependencies.usingDrift;
    riddles
      ..clear()
      ..addAll(dependencies.riddles);

    await _refreshProgress();
    await _refreshDaily();
    await _refreshAchievements();
    await _refreshProgress();
    loaded = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboarded = true;
    await _dependencies?.preferences.setBool('onboarded', true);
    notifyListeners();
  }

  List<Riddle> campaignRiddles(Testament testament) {
    return riddles.where((riddle) => riddle.testament == testament).toList();
  }

  List<SectionSummary> sections(Testament testament) {
    final grouped = <String, List<Riddle>>{};
    for (final riddle in campaignRiddles(testament)) {
      grouped.putIfAbsent(riddle.sectionId, () => []).add(riddle);
    }
    return grouped.entries
        .map(
          (entry) => SectionSummary(
            entry.key,
            _titleFromSectionId(entry.key),
            testament,
            entry.value,
          ),
        )
        .toList();
  }

  bool isCompleted(String riddleId) => starsByRiddle.containsKey(riddleId);

  bool isUnlocked(Riddle riddle) {
    final campaign = campaignRiddles(riddle.testament);
    final index = campaign.indexWhere((item) => item.id == riddle.id);
    if (index <= 0) return true;
    return isCompleted(campaign[index - 1].id);
  }

  int campaignCompleted(Testament testament) {
    return campaignRiddles(testament)
        .where((riddle) => isCompleted(riddle.id))
        .length;
  }

  int campaignStars(Testament testament) {
    return campaignRiddles(testament).fold(
      0,
      (total, riddle) => total + (starsByRiddle[riddle.id] ?? 0),
    );
  }

  Future<bool> spendHintCoin() async {
    final result = await _runtime!.spendHint();
    await _refreshProgress();
    notifyListeners();
    return result.success;
  }

  Future<AnswerResult> submitAnswer(
    Riddle riddle, {
    required String answer,
    required int attempts,
    required int hintsUsed,
  }) async {
    final result = await _runtime!.submitAnswer(
      riddle: riddle,
      answer: answer,
      attempts: attempts,
      hintsUsed: hintsUsed,
    );
    if (!result.correct) {
      await _runtime!.recordWrongAnswer();
    }
    await _refreshProgress();
    await _refreshAchievements();
    await _refreshProgress();
    notifyListeners();
    return result;
  }

  Future<DailyCompletionResult> completeDailyRiddle(
    Riddle riddle,
    int stars,
  ) async {
    final result = await _dailyRiddleService!.completeDailyRiddle(
      riddleId: riddle.id,
      stars: stars,
      date: DateTime.now(),
    );
    await _refreshDaily();
    await _refreshProgress();
    await _refreshAchievements();
    await _refreshProgress();
    notifyListeners();
    return result;
  }

  Future<void> resetProgress() async {
    await _progressRepository?.resetAllProgress();
    await _engagementRepository?.resetAllEngagement();
    await _refreshProgress();
    await _refreshDaily();
    await _refreshAchievements();
    await _refreshProgress();
    notifyListeners();
  }

  Future<void> _refreshProgress() async {
    final repository = _progressRepository;
    if (repository == null) return;

    final allProgress = await repository.getAllLevelProgress();
    starsByRiddle
      ..clear()
      ..addEntries(
        allProgress.entries
            .where((entry) => entry.value.completed)
            .map((entry) => MapEntry(entry.key, entry.value.stars)),
      );

    final economy = await repository.getEconomy();
    final statistics = await repository.getStatistics();
    coins = economy.coins;
    totalAnswers = statistics.totalAnswers;
    correctAnswers = statistics.correctAnswers;
    currentStreak = statistics.currentStreak;
    bestStreak = statistics.bestStreak;
    dailyStreak = statistics.dailyStreak;
  }

  Future<void> _refreshDaily() async {
    if (riddles.isEmpty || _dailyRiddleService == null) return;
    final record = await _dailyRiddleService!.ensureDailyRiddle(
      riddles: riddles,
      date: DateTime.now(),
    );
    dailyRecord = record;
    dailyRiddle = _findRiddle(record.riddleId) ??
        _dailyRiddleService!.selectRiddle(
          riddles: riddles,
          date: DateTime.now(),
        );
  }

  Future<void> _refreshAchievements() async {
    final repository = _progressRepository;
    final service = _achievementService;
    if (repository == null || service == null) return;

    final progress = await repository.getAllLevelProgress();
    final economy = await repository.getEconomy();
    final statistics = await repository.getStatistics();
    final completed = progress.values.where((item) => item.completed).toList();
    final result = await service.evaluate(
      AchievementSnapshot(
        completedLevels: completed.length,
        totalStars: completed.fold(0, (sum, item) => sum + item.stars),
        economy: economy,
        statistics: statistics,
      ),
    );
    achievements = result.states;
  }

  Riddle? _findRiddle(String id) {
    for (final riddle in riddles) {
      if (riddle.id == id) return riddle;
    }
    return null;
  }

  String _titleFromSectionId(String sectionId) {
    final parts = sectionId
        .split(RegExp(r'[-_]'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isNotEmpty && (parts.first == 'ot' || parts.first == 'nt')) {
      parts.removeAt(0);
    }
    return parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  @override
  void dispose() {
    final dependencies = _dependencies;
    if (dependencies != null) {
      unawaited(dependencies.dispose());
    }
    super.dispose();
  }
}
