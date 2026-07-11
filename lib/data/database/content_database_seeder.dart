import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../domain/entities/riddle.dart' as domain;

class ContentDatabaseSeeder {
  ContentDatabaseSeeder(this._database);

  final AppDatabase _database;

  Future<void> seedRiddles(List<domain.Riddle> riddles) async {
    await _database.transaction(() async {
      for (final riddle in riddles) {
        await _database.into(_database.riddles).insertOnConflictUpdate(
              RiddlesCompanion(
                id: Value(riddle.id),
                testament: Value(riddle.testament.key),
                book: Value(riddle.book),
                chapterStart: Value(riddle.chapterStart),
                chapterEnd: Value(riddle.chapterEnd),
                verseStart: Value(riddle.verseStart),
                verseEnd: Value(riddle.verseEnd),
                sectionId: Value(riddle.sectionId),
                topic: Value(riddle.topic),
                storyEventId: Value(riddle.storyEventId),
                questionType: Value(riddle.questionType),
                difficulty: Value(riddle.difficulty),
                question: Value(riddle.question),
                answer: Value(riddle.answer),
                acceptedAnswersJson: Value(jsonEncode(riddle.acceptedAnswers)),
                choicesJson: Value(jsonEncode(riddle.choices)),
                hintsJson: Value(jsonEncode(riddle.hints)),
                explanation: Value(riddle.explanation),
                reference: Value(riddle.reference),
                conceptTagsJson: Value(jsonEncode(riddle.conceptTags)),
                translationNotice: Value(riddle.translationNotice),
                contentStatus: Value(riddle.contentStatus),
                sortOrder: Value(riddle.sortOrder),
                version: Value(riddle.version),
              ),
            );
      }
    });
  }
}
