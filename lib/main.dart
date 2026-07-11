import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/bootstrap/runtime_bootstrap.dart';
import 'application/gameplay/gameplay_runtime.dart';
import 'application/gameplay/reward_rules.dart';
import 'domain/entities/riddle.dart';
import 'domain/entities/testament.dart';
import 'domain/repositories/progress_repository.dart';

void main() {
  runApp(const ProviderScope(child: BibleRiddleApp()));
}

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
  GameplayRuntime? _runtime;

  bool loaded = false;
  bool onboarded = false;
  bool usingDrift = false;
  int coins = 120;
  int totalAnswers = 0;
  int correctAnswers = 0;
  int currentStreak = 0;
  int bestStreak = 0;
  final Map<String, int> starsByRiddle = {};
  final List<Riddle> riddles = [];

  Future<void> load() async {
    final dependencies = await RuntimeBootstrap.create();
    _dependencies = dependencies;
    _progressRepository = dependencies.progressRepository;
    _runtime = dependencies.gameplayRuntime;

    onboarded = dependencies.preferences.getBool('onboarded') ?? false;
    usingDrift = dependencies.usingDrift;
    riddles
      ..clear()
      ..addAll(dependencies.riddles);

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
    notifyListeners();
    return result;
  }

  Future<void> resetProgress() async {
    await _progressRepository?.resetAllProgress();
    await _refreshProgress();
    notifyListeners();
  }

  Future<void> _refreshProgress() async {
    final repo = _progressRepository;
    if (repo == null) return;

    final allProgress = await repo.getAllLevelProgress();
    starsByRiddle
      ..clear()
      ..addEntries(
        allProgress.entries
            .where((entry) => entry.value.completed)
            .map((entry) => MapEntry(entry.key, entry.value.stars)),
      );

    final economy = await repo.getEconomy();
    final statistics = await repo.getStatistics();
    coins = economy.coins;
    totalAnswers = statistics.totalAnswers;
    correctAnswers = statistics.correctAnswers;
    currentStreak = statistics.currentStreak;
    bestStreak = statistics.bestStreak;
  }

  String _titleFromSectionId(String sectionId) {
    return sectionId
        .split(RegExp(r'[-_]'))
        .where((part) => part.isNotEmpty)
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

class BibleRiddleApp extends ConsumerWidget {
  const BibleRiddleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bible Riddle',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB08A31),
          brightness: Brightness.light,
          surface: const Color(0xFFFFF8E7),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFCF4),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD6B45C),
          brightness: Brightness.dark,
        ),
      ),
      home: !state.loaded
          ? const SplashScreen()
          : state.onboarded
              ? const HomeScreen()
              : const OnboardingScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 72),
            SizedBox(height: 16),
            Text(
              'Bible Riddle',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final controller = PageController();
  int page = 0;
  final pages = const [
    (
      'Learn through Bible riddles',
      'Read peaceful riddles, answer, and learn from short explanations.',
    ),
    (
      'Choose a campaign',
      'Progress separately through Old Testament and New Testament levels.',
    ),
    (
      'Earn hints and stars',
      'Use coins for optional hints. Ads are always optional in later phases.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      ref.read(gameProvider).completeOnboarding(),
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (value) => setState(() => page = value),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_stories_rounded, size: 96),
                        const SizedBox(height: 32),
                        Text(
                          pages[index].$1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          pages[index].$2,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    );
                  },
                ),
              ),
              FilledButton(
                onPressed: () {
                  if (page == pages.length - 1) {
                    ref.read(gameProvider).completeOnboarding();
                  } else {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(
                  page == pages.length - 1 ? 'Get Started' : 'Continue',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final total = state.riddles.length;
    final done = state.starsByRiddle.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Riddle'),
        actions: [
          IconButton(
            onPressed: () => _push(context, const SettingsScreen()),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Peaceful Bible riddles',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$done of $total sample levels completed • '
                    '${state.coins} coins • streak ${state.currentStreak}',
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _CampaignCard(testament: Testament.old),
          const _CampaignCard(testament: Testament.newTestament),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => _push(context, const ProgressScreen()),
            icon: const Icon(Icons.bar_chart_rounded),
            label: const Text('View Progress'),
          ),
        ],
      ),
    );
  }
}

class _CampaignCard extends ConsumerWidget {
  const _CampaignCard({required this.testament});

  final Testament testament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final total = state.campaignRiddles(testament).length;
    final done = state.campaignCompleted(testament);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Icon(
          testament == Testament.old
              ? Icons.history_edu_rounded
              : Icons.church_rounded,
          size: 40,
        ),
        title: Text(
          testament.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$done/$total completed • ${state.campaignStars(testament)} stars',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _push(
          context,
          CampaignScreen(testament: testament),
        ),
      ),
    );
  }
}

class CampaignScreen extends ConsumerWidget {
  const CampaignScreen({super.key, required this.testament});

  final Testament testament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final sections = state.sections(testament);
    return Scaffold(
      appBar: AppBar(title: Text(testament.label)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          final done = section.riddles
              .where((riddle) => state.isCompleted(riddle.id))
              .length;
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              title: Text(
                section.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('$done/${section.riddles.length} levels completed'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _push(
                context,
                LevelScreen(section: section),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LevelScreen extends ConsumerWidget {
  const LevelScreen({super.key, required this.section});

  final SectionSummary section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: section.riddles.length,
        itemBuilder: (context, index) {
          final riddle = section.riddles[index];
          final unlocked = state.isUnlocked(riddle);
          final stars = state.starsByRiddle[riddle.id] ?? 0;
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(riddle.topic),
              subtitle: Text(
                '${riddle.book} • Difficulty ${riddle.difficulty} • '
                '${'★' * stars}${'☆' * (3 - stars)}',
              ),
              trailing: Icon(
                unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
              ),
              enabled: unlocked,
              onTap: unlocked
                  ? () => _push(
                        context,
                        GameplayScreen(riddle: riddle),
                      )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class GameplayScreen extends ConsumerStatefulWidget {
  const GameplayScreen({super.key, required this.riddle});

  final Riddle riddle;

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  final textController = TextEditingController();
  String? selectedChoice;
  String feedback = '';
  int attempts = 0;
  int hintsUsed = 0;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final riddle = widget.riddle;
    return Scaffold(
      appBar: AppBar(
        title: Text('${riddle.testament.label} • Level ${riddle.sortOrder}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${riddle.book} • ${riddle.reference}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    riddle.question,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  if (riddle.isTypedAnswer)
                    TextField(
                      controller: textController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Type your answer',
                      ),
                      onSubmitted: (_) => _submit(),
                    )
                  else
                    ...riddle.choices.map(
                      (choice) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ChoiceChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(choice),
                          ),
                          selected: selectedChoice == choice,
                          onSelected: (_) =>
                              setState(() => selectedChoice = choice),
                        ),
                      ),
                    ),
                  if (feedback.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      feedback,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Coins: ${state.coins} • Hints used: $hintsUsed'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
              OutlinedButton.icon(
                onPressed: state.coins >= hintCoinCost &&
                        hintsUsed < riddle.hints.length
                    ? _hint
                    : null,
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: const Text('Use $hintCoinCost coins'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _hint() async {
    final spent = await ref.read(gameProvider).spendHintCoin();
    if (!mounted) return;
    if (!spent) {
      setState(() => feedback = 'Not enough coins for a hint.');
      return;
    }
    setState(() {
      feedback = widget.riddle.hints[hintsUsed];
      hintsUsed += 1;
    });
  }

  Future<void> _submit() async {
    final riddle = widget.riddle;
    final answer =
        riddle.isTypedAnswer ? textController.text : selectedChoice ?? '';
    if (answer.trim().isEmpty) {
      setState(() => feedback = 'Choose or type an answer first.');
      return;
    }

    attempts += 1;
    final result = await ref.read(gameProvider).submitAnswer(
          riddle,
          answer: answer,
          attempts: attempts,
          hintsUsed: hintsUsed,
        );

    if (!mounted) return;
    if (result.correct) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Correct'),
          content: Text(
            '${riddle.answer}\n\n${riddle.explanation}\n\n'
            'Reference: ${riddle.reference}\n\n'
            'Earned: ${result.stars} stars and '
            '${result.coinsAwarded} coins',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        feedback = result.veryClose
            ? 'Very close. Check the spelling and try again.'
            : 'Not quite. Try again, use a hint, or reveal another clue.';
      });
    }
  }
}

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final rate = state.totalAnswers == 0
        ? 0
        : (state.correctAnswers / state.totalAnswers * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatTile('Coins', '${state.coins}'),
          _StatTile('Answered', '${state.totalAnswers}'),
          _StatTile('Correct rate', '$rate%'),
          _StatTile('Current streak', '${state.currentStreak}'),
          _StatTile('Best streak', '${state.bestStreak}'),
          _StatTile(
            'Old Testament',
            '${state.campaignCompleted(Testament.old)}/'
                '${state.campaignRiddles(Testament.old).length} completed',
          ),
          _StatTile(
            'New Testament',
            '${state.campaignCompleted(Testament.newTestament)}/'
                '${state.campaignRiddles(Testament.newTestament).length} '
                'completed',
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ListTile(
            title: Text('Ads'),
            subtitle: Text(
              'No forced ads. Rewarded ads are optional and belong in a '
              'later phase.',
            ),
          ),
          const ListTile(
            title: Text('Content status'),
            subtitle: Text('Sample riddles are marked needs_review.'),
          ),
          ListTile(
            title: const Text('Storage'),
            subtitle: Text(
              state.usingDrift
                  ? 'Progress is stored offline in Drift SQLite.'
                  : 'SQLite initialization failed, so the safe local '
                      'SharedPreferences fallback is active.',
            ),
          ),
          const ListTile(
            title: Text('Accessibility'),
            subtitle: Text(
              'Uses Material controls, readable type, labels, and '
              'color-independent feedback.',
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () async {
              await ref.read(gameProvider).resetProgress();
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset progress'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.title, this.value);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

void _push(BuildContext context, Widget screen) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => screen),
  );
}
