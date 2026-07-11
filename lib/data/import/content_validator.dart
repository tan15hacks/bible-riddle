import '../../domain/entities/game_content.dart';

class ContentValidationResult {
  ContentValidationResult({required this.criticalErrors, required this.warnings});

  final List<String> criticalErrors;
  final List<String> warnings;

  bool get hasCriticalErrors => criticalErrors.isNotEmpty;
}

class ContentValidator {
  ContentValidationResult validate(GameContent content) {
    final critical = <String>[];
    final warnings = <String>[];
    final byId = <String, String>{};
    final normalizedQuestions = <String, String>{};
    final storyEvents = <String, String>{};
    final explanations = <String, String>{};

    for (final riddle in content.riddles) {
      if (byId.containsKey(riddle.id)) critical.add('Duplicate id: ${riddle.id}');
      byId[riddle.id] = riddle.id;

      if (riddle.reference.trim().isEmpty) critical.add('Missing reference: ${riddle.id}');
      if (riddle.explanation.trim().isEmpty) critical.add('Missing explanation: ${riddle.id}');
      if (riddle.hints.length < 3) critical.add('Missing hints: ${riddle.id}');
      if (riddle.difficulty < 1 || riddle.difficulty > 10) critical.add('Invalid difficulty: ${riddle.id}');
      if (riddle.choices.isNotEmpty && !riddle.choices.contains(riddle.answer)) critical.add('Answer not present in choices: ${riddle.id}');

      final accepted = riddle.acceptedAnswers.map(_norm).toSet();
      final correctChoiceCount = riddle.choices.where((choice) => accepted.contains(_norm(choice))).length;
      if (riddle.choices.isNotEmpty && correctChoiceCount != 1) critical.add('Expected exactly one correct choice: ${riddle.id}');

      final q = _norm(riddle.question);
      final priorQuestion = normalizedQuestions[q];
      if (priorQuestion != null) critical.add('Duplicate normalized question: $priorQuestion and ${riddle.id}');
      normalizedQuestions[q] = riddle.id;

      final priorStory = storyEvents[riddle.storyEventId];
      if (priorStory != null) critical.add('Repeated storyEventId: $priorStory and ${riddle.id}');
      storyEvents[riddle.storyEventId] = riddle.id;

      final explanation = _norm(riddle.explanation);
      final priorExplanation = explanations[explanation];
      if (priorExplanation != null) critical.add('Duplicate explanation: $priorExplanation and ${riddle.id}');
      explanations[explanation] = riddle.id;

      if (riddle.contentStatus != 'reviewed') {
        warnings.add('${riddle.id} is ${riddle.contentStatus}; do not ship as production content.');
      }
    }

    return ContentValidationResult(criticalErrors: critical, warnings: warnings);
  }

  String _norm(String value) => value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}
