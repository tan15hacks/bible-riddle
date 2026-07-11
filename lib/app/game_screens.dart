import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/engagement/daily_riddle_service.dart';
import '../application/gameplay/reward_rules.dart';
import '../domain/entities/engagement.dart';
import '../domain/entities/riddle.dart';
import '../domain/entities/testament.dart';
import 'game_controller.dart';

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
  final PageController controller = PageController();
  int page = 0;

  static const pages = [
    (
      'Learn through Bible riddles',
      'Read peaceful riddles, answer, and learn from short explanations.',
    ),
    (
      'Choose a campaign',
      'Progress separately through Old Testament and New Testament levels.',
    ),
    (
      'Build a daily habit',
      'Complete the Daily Riddle, earn achievements, stars, and coins.',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => page = value),
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
            onPressed: () => pushScreen(context, const SettingsScreen()),
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
                    '$done of $total levels completed • ${state.coins} coins',
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
          _DailyRiddleCard(state: state),
          const SizedBox(height: 12),
          const _CampaignCard(testament: Testament.old),
          const _CampaignCard(testament: Testament.newTestament),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: const Icon(Icons.emoji_events_rounded, size: 40),
              title: const Text(
                'Achievements',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${state.achievementUnlockedCount}/'
                '${state.achievements.length} unlocked',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => pushScreen(context, const AchievementsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => pushScreen(context, const ProgressScreen()),
            icon: const Icon(Icons.bar_chart_rounded),
            label: const Text('View Progress'),
          ),
        ],
      ),
    );
  }
}

class _DailyRiddleCard extends StatelessWidget {
  const _DailyRiddleCard({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final riddle = state.dailyRiddle;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Icon(
          state.dailyCompleted
              ? Icons.check_circle_rounded
              : Icons.calendar_today_rounded,
          size: 40,
        ),
        title: const Text(
          'Daily Riddle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          state.dailyCompleted
              ? 'Completed today • ${state.dailyStreak}-day streak'
              : 'Earn $dailyRiddleBonusCoins bonus coins today',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        enabled: riddle != null,
        onTap: riddle == null
            ? null
            : () => pushScreen(
                  context,
                  GameplayScreen(riddle: riddle, dailyMode: true),
                ),
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
        onTap: () => pushScreen(
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
              subtitle: Text('$done/${section.riddles.length} completed'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => pushScreen(
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
                  ? () => pushScreen(
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
  const GameplayScreen({
    super.key,
    required this.riddle,
    this.dailyMode = false,
  });

  final Riddle riddle;
  final bool dailyMode;

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  final TextEditingController textController = TextEditingController();
  String? selectedChoice;
  String feedback = '';
  int attempts = 0;
  int hintsUsed = 0;
  bool submitting = false;

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
        title: Text(
          widget.dailyMode
              ? 'Daily Riddle'
              : '${riddle.testament.label} • Level ${riddle.sortOrder}',
        ),
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
                      enabled: !submitting,
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
                          onSelected: submitting
                              ? null
                              : (_) =>
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
                onPressed: submitting ? null : _submit,
                child: const Text('Submit'),
              ),
              OutlinedButton.icon(
                onPressed: !submitting &&
                        state.coins >= hintCoinCost &&
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

    setState(() => submitting = true);
    attempts += 1;
    final state = ref.read(gameProvider);
    final result = await state.submitAnswer(
      riddle,
      answer: answer,
      attempts: attempts,
      hintsUsed: hintsUsed,
    );

    if (!mounted) return;
    if (!result.correct) {
      setState(() {
        submitting = false;
        feedback = result.veryClose
            ? 'Very close. Check the spelling and try again.'
            : 'Not quite. Try again or use a hint.';
      });
      return;
    }

    DailyCompletionResult? dailyResult;
    if (widget.dailyMode) {
      dailyResult = await state.completeDailyRiddle(riddle, result.stars);
    }
    if (!mounted) return;

    final dailyText = dailyResult == null
        ? ''
        : dailyResult.wasAlreadyCompleted
            ? '\n\nDaily reward was already claimed.'
            : '\n\nDaily bonus: ${dailyResult.coinsAwarded} coins • '
                '${dailyResult.dailyStreak}-day streak';
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Correct'),
        content: Text(
          '${riddle.answer}\n\n${riddle.explanation}\n\n'
          'Reference: ${riddle.reference}\n\n'
          'Earned: ${result.stars} stars and '
          '${result.coinsAwarded} coins$dailyText',
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
  }
}

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final states = ref.watch(gameProvider).achievements;
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: states.length,
        itemBuilder: (context, index) {
          final state = states[index];
          return _AchievementCard(state: state);
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.state});

  final AchievementState state;

  @override
  Widget build(BuildContext context) {
    final unlocked = state.record.unlocked;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(unlocked ? Icons.emoji_events : Icons.lock_outline),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.definition.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(state.definition.description),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: state.completionRatio),
                  const SizedBox(height: 6),
                  Text(
                    unlocked
                        ? 'Unlocked • +${state.definition.rewardCoins} coins'
                        : '${state.record.progress}/${state.record.target}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          _StatTile('Daily streak', '${state.dailyStreak} days'),
          _StatTile(
            'Achievements',
            '${state.achievementUnlockedCount}/${state.achievements.length}',
          ),
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
            subtitle: Text('No forced ads. Rewarded ads remain optional.'),
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
                  : 'The safe SharedPreferences fallback is active.',
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () async {
              await ref.read(gameProvider).resetProgress();
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset all progress'),
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

void pushScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => screen),
  );
}
