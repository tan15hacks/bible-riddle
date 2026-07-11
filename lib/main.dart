import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(child: BibleRiddleApp()));
}

final gameProvider = ChangeNotifierProvider<GameState>((ref) => GameState()..load());

enum Testament { old, newTestament }

extension TestamentLabel on Testament {
  String get key => this == Testament.old ? 'old' : 'new';
  String get label => this == Testament.old ? 'Old Testament' : 'New Testament';
}

String normalizeAnswer(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'[’‘`´]'), "'")
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool isAcceptedAnswer(String input, List<String> acceptedAnswers) {
  final normalized = normalizeAnswer(input);
  return acceptedAnswers.any((answer) => normalizeAnswer(answer) == normalized);
}

bool isVeryCloseAnswer(String input, List<String> acceptedAnswers) {
  final normalized = normalizeAnswer(input);
  if (normalized.isEmpty) return false;
  for (final answer in acceptedAnswers.map(normalizeAnswer)) {
    if ((answer.contains(normalized) || normalized.contains(answer)) && normalized.length >= 3) {
      return true;
    }
  }
  return false;
}

int calculateStars({required int attempts, required int hintsUsed}) {
  if (attempts <= 1 && hintsUsed == 0) return 3;
  if (attempts <= 2 && hintsUsed <= 1) return 2;
  return 1;
}

int calculateCoins({required int difficulty, required int stars}) {
  return 10 + (difficulty >= 4 ? 5 : 0) + (stars == 3 ? 5 : 0);
}

class Riddle {
  const Riddle({
    required this.id,
    required this.testament,
    required this.sectionId,
    required this.sectionTitle,
    required this.book,
    required this.reference,
    required this.topic,
    required this.storyEventId,
    required this.questionType,
    required this.difficulty,
    required this.question,
    required this.answer,
    required this.acceptedAnswers,
    required this.choices,
    required this.hints,
    required this.explanation,
    required this.contentStatus,
    required this.sortOrder,
  });

  final String id;
  final Testament testament;
  final String sectionId;
  final String sectionTitle;
  final String book;
  final String reference;
  final String topic;
  final String storyEventId;
  final String questionType;
  final int difficulty;
  final String question;
  final String answer;
  final List<String> acceptedAnswers;
  final List<String> choices;
  final List<String> hints;
  final String explanation;
  final String contentStatus;
  final int sortOrder;

  bool get isTyped => choices.isEmpty;

  factory Riddle.fromJson(Map<String, dynamic> json) {
    return Riddle(
      id: json['id'] as String,
      testament: json['testament'] == 'old' ? Testament.old : Testament.newTestament,
      sectionId: json['sectionId'] as String,
      sectionTitle: json['sectionTitle'] as String,
      book: json['book'] as String,
      reference: json['reference'] as String,
      topic: json['topic'] as String,
      storyEventId: json['storyEventId'] as String,
      questionType: json['questionType'] as String,
      difficulty: json['difficulty'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
      acceptedAnswers: List<String>.from(json['acceptedAnswers'] as List),
      choices: List<String>.from(json['choices'] as List),
      hints: List<String>.from(json['hints'] as List),
      explanation: json['explanation'] as String,
      contentStatus: json['contentStatus'] as String,
      sortOrder: json['sortOrder'] as int,
    );
  }
}

class SectionSummary {
  SectionSummary(this.id, this.title, this.testament, this.riddles);
  final String id;
  final String title;
  final Testament testament;
  final List<Riddle> riddles;
}

class GameState extends ChangeNotifier {
  bool loaded = false;
  bool onboarded = false;
  int coins = 120;
  int totalAnswers = 0;
  int correctAnswers = 0;
  int currentStreak = 0;
  int bestStreak = 0;
  final Map<String, int> starsByRiddle = {};
  final List<Riddle> riddles = [];
  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    onboarded = _prefs!.getBool('onboarded') ?? false;
    coins = _prefs!.getInt('coins') ?? 120;
    totalAnswers = _prefs!.getInt('totalAnswers') ?? 0;
    correctAnswers = _prefs!.getInt('correctAnswers') ?? 0;
    currentStreak = _prefs!.getInt('currentStreak') ?? 0;
    bestStreak = _prefs!.getInt('bestStreak') ?? 0;
    final starsJson = _prefs!.getString('starsByRiddle');
    if (starsJson != null) {
      final decoded = jsonDecode(starsJson) as Map<String, dynamic>;
      starsByRiddle.addAll(decoded.map((key, value) => MapEntry(key, value as int)));
    }
    final content = await rootBundle.loadString('assets/data/riddles_phase_a.json');
    final decoded = jsonDecode(content) as Map<String, dynamic>;
    riddles
      ..clear()
      ..addAll((decoded['riddles'] as List).map((item) => Riddle.fromJson(item as Map<String, dynamic>)));
    riddles.sort((a, b) {
      final testamentCompare = a.testament.index.compareTo(b.testament.index);
      if (testamentCompare != 0) return testamentCompare;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    loaded = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboarded = true;
    await _prefs?.setBool('onboarded', true);
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
        .map((entry) => SectionSummary(entry.key, entry.value.first.sectionTitle, testament, entry.value))
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
    return campaignRiddles(testament).where((riddle) => isCompleted(riddle.id)).length;
  }

  int campaignStars(Testament testament) {
    return campaignRiddles(testament).fold(0, (total, riddle) => total + (starsByRiddle[riddle.id] ?? 0));
  }

  Future<void> spendHintCoin() async {
    coins -= 30;
    await _save();
    notifyListeners();
  }

  Future<void> recordWrongAnswer() async {
    totalAnswers += 1;
    currentStreak = 0;
    await _save();
    notifyListeners();
  }

  Future<int> completeRiddle(Riddle riddle, {required int attempts, required int hintsUsed}) async {
    final stars = calculateStars(attempts: attempts, hintsUsed: hintsUsed);
    final previousStars = starsByRiddle[riddle.id] ?? 0;
    if (stars > previousStars) {
      starsByRiddle[riddle.id] = stars;
    }
    final reward = calculateCoins(difficulty: riddle.difficulty, stars: stars);
    coins += reward;
    totalAnswers += 1;
    correctAnswers += 1;
    currentStreak += 1;
    if (currentStreak > bestStreak) bestStreak = currentStreak;
    await _save();
    notifyListeners();
    return reward;
  }

  Future<void> resetProgress() async {
    starsByRiddle.clear();
    coins = 120;
    totalAnswers = 0;
    correctAnswers = 0;
    currentStreak = 0;
    bestStreak = 0;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    await _prefs?.setInt('coins', coins);
    await _prefs?.setInt('totalAnswers', totalAnswers);
    await _prefs?.setInt('correctAnswers', correctAnswers);
    await _prefs?.setInt('currentStreak', currentStreak);
    await _prefs?.setInt('bestStreak', bestStreak);
    await _prefs?.setString('starsByRiddle', jsonEncode(starsByRiddle));
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD6B45C), brightness: Brightness.dark),
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
            Text('Bible Riddle', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
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
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final controller = PageController();
  int page = 0;
  final pages = const [
    ('Learn through Bible riddles', 'Read peaceful riddles, answer, and learn from short explanations.'),
    ('Choose a campaign', 'Progress separately through Old Testament and New Testament levels.'),
    ('Earn hints and stars', 'Use coins for optional hints. Ads and purchases are not required in Phase A.'),
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
                  onPressed: () => ref.read(gameProvider).completeOnboarding(),
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
                        Text(pages[index].$1, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(pages[index].$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
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
                    controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                  }
                },
                child: Text(page == pages.length - 1 ? 'Get Started' : 'Continue'),
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
      appBar: AppBar(title: const Text('Bible Riddle'), actions: [IconButton(onPressed: () => _push(context, const SettingsScreen()), icon: const Icon(Icons.settings_rounded))]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Peaceful Bible riddles', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('$done of $total sample levels completed • ${state.coins} coins • streak ${state.currentStreak}'),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: total == 0 ? 0 : done / total),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          _CampaignCard(testament: Testament.old),
          _CampaignCard(testament: Testament.newTestament),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(onPressed: () => _push(context, const ProgressScreen()), icon: const Icon(Icons.bar_chart_rounded), label: const Text('View Progress')),
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
        leading: Icon(testament == Testament.old ? Icons.history_edu_rounded : Icons.church_rounded, size: 40),
        title: Text(testament.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$done/$total completed • ${state.campaignStars(testament)} stars'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _push(context, CampaignScreen(testament: testament)),
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
          final done = section.riddles.where((riddle) => state.isCompleted(riddle.id)).length;
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$done/${section.riddles.length} levels completed'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _push(context, LevelScreen(section: section)),
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
              subtitle: Text('${riddle.book} • Difficulty ${riddle.difficulty} • ${'★' * stars}${'☆' * (3 - stars)}'),
              trailing: Icon(unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded),
              enabled: unlocked,
              onTap: unlocked ? () => _push(context, GameplayScreen(riddle: riddle)) : null,
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
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final riddle = widget.riddle;
    return Scaffold(
      appBar: AppBar(title: Text('${riddle.testament.label} • Level ${riddle.sortOrder}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('${riddle.book} • ${riddle.reference}', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(riddle.question, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                if (riddle.isTyped)
                  TextField(
                    controller: textController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Type your answer'),
                    onSubmitted: (_) => _submit(),
                  )
                else
                  ...riddle.choices.map((choice) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ChoiceChip(
                          label: SizedBox(width: double.infinity, child: Text(choice)),
                          selected: selectedChoice == choice,
                          onSelected: (_) => setState(() => selectedChoice = choice),
                        ),
                      )),
                if (feedback.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(feedback, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Text('Coins: ${state.coins} • Hints used: $hintsUsed'),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            FilledButton(onPressed: _submit, child: const Text('Submit')),
            OutlinedButton.icon(onPressed: state.coins >= 30 && hintsUsed < riddle.hints.length ? _hint : null, icon: const Icon(Icons.lightbulb_outline_rounded), label: const Text('Use 30 coins')),
          ]),
        ],
      ),
    );
  }

  Future<void> _hint() async {
    await ref.read(gameProvider).spendHintCoin();
    setState(() {
      feedback = widget.riddle.hints[hintsUsed];
      hintsUsed += 1;
    });
  }

  Future<void> _submit() async {
    final riddle = widget.riddle;
    final answer = riddle.isTyped ? textController.text : selectedChoice ?? '';
    if (answer.trim().isEmpty) {
      setState(() => feedback = 'Choose or type an answer first.');
      return;
    }
    attempts += 1;
    if (isAcceptedAnswer(answer, [riddle.answer, ...riddle.acceptedAnswers])) {
      final reward = await ref.read(gameProvider).completeRiddle(riddle, attempts: attempts, hintsUsed: hintsUsed);
      final stars = calculateStars(attempts: attempts, hintsUsed: hintsUsed);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Correct'),
          content: Text('${riddle.answer}\n\n${riddle.explanation}\n\nReference: ${riddle.reference}\n\nEarned: $stars stars and $reward coins'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continue'))],
        ),
      );
      if (mounted) Navigator.pop(context);
    } else {
      await ref.read(gameProvider).recordWrongAnswer();
      setState(() {
        feedback = isVeryCloseAnswer(answer, [riddle.answer, ...riddle.acceptedAnswers])
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
    final rate = state.totalAnswers == 0 ? 0 : (state.correctAnswers / state.totalAnswers * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _StatTile('Coins', '${state.coins}'),
        _StatTile('Answered', '${state.totalAnswers}'),
        _StatTile('Correct rate', '$rate%'),
        _StatTile('Current streak', '${state.currentStreak}'),
        _StatTile('Best streak', '${state.bestStreak}'),
        _StatTile('Old Testament', '${state.campaignCompleted(Testament.old)}/${state.campaignRiddles(Testament.old).length} completed'),
        _StatTile('New Testament', '${state.campaignCompleted(Testament.newTestament)}/${state.campaignRiddles(Testament.newTestament).length} completed'),
      ]),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const ListTile(title: Text('Ads'), subtitle: Text('Phase A has no forced ads and no required internet.')),
        const ListTile(title: Text('Content status'), subtitle: Text('Sample riddles are marked needs_review.')),
        const ListTile(title: Text('Accessibility'), subtitle: Text('Uses Material controls, readable type, labels, and color-independent feedback.')),
        FilledButton.tonalIcon(
          onPressed: () async {
            await ref.read(gameProvider).resetProgress();
            if (context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text('Reset progress'),
        ),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.title, this.value);
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(title), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))));
  }
}

void _push(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}
