import 'package:bible_riddle/data/import/content_validator.dart';
import 'package:bible_riddle/domain/entities/riddle.dart';
import 'package:bible_riddle/domain/entities/testament.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Riddle sample({
    String id = 'OT-GEN-001-001',
    String storyEventId = 'creation-light',
    String question = 'I was called forth before the sun and moon. What am I?',
    String answer = 'Light',
    List<String> choices = const ['Light', 'Water', 'Land', 'Stars'],
    String reference = 'Genesis 1:3',
    int difficulty = 1,
  }) {
    return Riddle(
      id: id,
      testament: Testament.old,
      book: 'Genesis',
      chapterStart: 1,
      chapterEnd: 1,
      verseStart: 3,
      verseEnd: 3,
      sectionId: 'creation',
      topic: 'Creation of light',
      storyEventId: storyEventId,
      conceptTags: const ['creation', 'light'],
      questionType: 'object_riddle',
      difficulty: difficulty,
      question: question,
      answer: answer,
      acceptedAnswers: [answer],
      choices: choices,
      hints: const ['Creation account', 'First day', 'It begins with L'],
      explanation: 'Genesis describes God calling light into being.',
      reference: reference,
      translationNotice: '',
      contentStatus: 'needs_review',
      sortOrder: 1,
      version: 1,
    );
  }

  test('validator accepts structurally valid riddle with review warning', () {
    final report = const ContentValidator().validate([sample()]);
    expect(report.criticalErrors, isEmpty);
    expect(report.warnings, isNotEmpty);
    expect(report.canImport, isTrue);
  });

  test('validator catches duplicate concept events', () {
    final report = const ContentValidator().validate([
      sample(id: 'a'),
      sample(id: 'b', question: 'A different question?', storyEventId: 'creation-light'),
    ]);
    expect(report.criticalErrors.any((error) => error.contains('Repeated storyEventId')), isTrue);
  });

  test('validator blocks missing references', () {
    final report = const ContentValidator().validate([sample(reference: '')]);
    expect(report.canImport, isFalse);
    expect(report.criticalErrors.any((error) => error.contains('Missing reference')), isTrue);
  });

  test('validator blocks answer not present in choices', () {
    final report = const ContentValidator().validate([
      sample(answer: 'Light', choices: const ['Water', 'Land', 'Stars', 'Sky']),
    ]);
    expect(report.canImport, isFalse);
  });
}
