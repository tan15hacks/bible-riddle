import '../../domain/entities/riddle.dart';
import 'content_import_report.dart';

class ContentValidator {
  const ContentValidator();

  ContentImportReport validate(List<Riddle> riddles) {
    final errors = <String>[];
    final warnings = <String>[];
    final ids = <String>{};
    final questions = <String>{};
    final storyEvents = <String>{};
    final referenceTypePairs = <String>{};
    final explanations = <String>{};

    for (final riddle in riddles) {
      if (!ids.add(riddle.id)) {
        errors.add('Duplicate riddle id: ${riddle.id}');
      }

      final normalizedQuestion = _normalize(riddle.question);
      if (!questions.add(normalizedQuestion)) {
        errors.add('Duplicate normalized question: ${riddle.id}');
      }

      if (!storyEvents.add(riddle.storyEventId)) {
        errors.add('Repeated storyEventId: ${riddle.storyEventId}');
      }

      final refType = '${_normalize(riddle.reference)}:${riddle.questionType}';
      if (!referenceTypePairs.add(refType)) {
        warnings.add('Repeated reference and question type: ${riddle.reference} / ${riddle.questionType}');
      }

      final explanation = _normalize(riddle.explanation);
      if (!explanations.add(explanation)) {
        warnings.add('Duplicate explanation near ${riddle.id}');
      }

      if (riddle.reference.trim().isEmpty) {
        errors.add('Missing reference: ${riddle.id}');
      }
      if (riddle.explanation.trim().isEmpty) {
        errors.add('Missing explanation: ${riddle.id}');
      }
      if (riddle.hints.length < 3) {
        warnings.add('Less than three hints: ${riddle.id}');
      }
      if (riddle.difficulty < 1 || riddle.difficulty > 10) {
        errors.add('Invalid difficulty ${riddle.difficulty}: ${riddle.id}');
      }
      if (riddle.choices.isNotEmpty && !riddle.choices.contains(riddle.answer)) {
        errors.add('Answer not present in choices: ${riddle.id}');
      }
      final matchingChoices = riddle.choices.where((choice) => _accepted(choice, riddle.acceptedAnswers)).length;
      if (matchingChoices > 1) {
        errors.add('Multiple correct choices: ${riddle.id}');
      }
      if (riddle.contentStatus != 'reviewed' && riddle.contentStatus != 'needs_review') {
        errors.add('Invalid contentStatus ${riddle.contentStatus}: ${riddle.id}');
      }
      if (riddle.contentStatus == 'needs_review') {
        warnings.add('Needs content review before production: ${riddle.id}');
      }
    }

    return ContentImportReport(totalRiddles: riddles.length, criticalErrors: errors, warnings: warnings);
  }

  bool _accepted(String value, List<String> acceptedAnswers) {
    final normalized = _normalize(value);
    return acceptedAnswers.any((answer) => _normalize(answer) == normalized);
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
