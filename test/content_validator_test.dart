import 'package:bible_riddle/data/import/content_validator.dart';
import 'package:bible_riddle/domain/entities/game_content.dart';
import 'package:bible_riddle/domain/entities/riddle.dart';
import 'package:bible_riddle/domain/entities/testament.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validator blocks duplicate story events', () {
    final validator = ContentValidator();
    final content = GameContent(sections: const [], riddles: <Riddle>[
      _riddle(id: 'OT-GEN-001', question: 'Who built the ark?'),
      _riddle(id: 'OT-GEN-002', question: 'Which man prepared a large boat?'),
    ]);

    final result = validator.validate(content);

    expect(result.hasCriticalErrors, isTrue);
    expect(result.criticalErrors.any((item) => item.contains('Repeated storyEventId')), isTrue);
  });

  test('validator warns for unreviewed content', () {
    final validator = ContentValidator();
    final content = GameContent(sections: const [], riddles: <Riddle>[
      _riddle(id: 'OT-GEN-001', question: 'Who built the ark?', storyEventId: 'noah-builds-ark'),
    ]);

    final result = validator.validate(content);

    expect(result.hasCriticalErrors, isFalse);
    expect(result.warnings.single, contains('needs_review'));
  });
}

Riddle _riddle({required String id, required String question, String storyEventId = 'same-event'}) {
  return Riddle(
    id: id,
    testament: Testament.old,
    book: 'Genesis',
    chapterStart: 6,
    chapterEnd: 9,
    verseStart: 1,
    verseEnd: 29,
    sectionId: 'ot-beginnings',
    topic: 'Noah and the ark',
    storyEventId: storyEventId,
    conceptTags: const ['Noah', 'ark'],
    questionType: 'character_riddle',
    difficulty: 1,
    question: question,
    answer: 'Noah',
    acceptedAnswers: const ['Noah'],
    choices: const ['Noah', 'Moses', 'Abraham', 'Jacob'],
    hints: const ['He was righteous in his generation.', 'His name begins with N.', 'N _ A H'],
    explanation: 'Noah built the ark before the flood.',
    reference: 'Genesis 6–9',
    translationNotice: '',
    contentStatus: 'needs_review',
    sortOrder: 1,
  );
}
