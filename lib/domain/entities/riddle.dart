import 'testament.dart';

class Riddle {
  const Riddle({
    required this.id,
    required this.testament,
    required this.book,
    required this.chapterStart,
    required this.chapterEnd,
    required this.verseStart,
    required this.verseEnd,
    required this.sectionId,
    required this.topic,
    required this.storyEventId,
    required this.conceptTags,
    required this.questionType,
    required this.difficulty,
    required this.question,
    required this.answer,
    required this.acceptedAnswers,
    required this.choices,
    required this.hints,
    required this.explanation,
    required this.reference,
    required this.translationNotice,
    required this.contentStatus,
    required this.sortOrder,
  });

  final String id;
  final Testament testament;
  final String book;
  final int chapterStart;
  final int chapterEnd;
  final int verseStart;
  final int verseEnd;
  final String sectionId;
  final String topic;
  final String storyEventId;
  final List<String> conceptTags;
  final String questionType;
  final int difficulty;
  final String question;
  final String answer;
  final List<String> acceptedAnswers;
  final List<String> choices;
  final List<String> hints;
  final String explanation;
  final String reference;
  final String translationNotice;
  final String contentStatus;
  final int sortOrder;

  bool get isTypedAnswer => choices.isEmpty;

  factory Riddle.fromJson(Map<String, dynamic> json) {
    return Riddle(
      id: json['id'] as String,
      testament: Testament.fromStorage(json['testament'] as String),
      book: json['book'] as String,
      chapterStart: json['chapterStart'] as int? ?? json['chapter_start'] as int? ?? 0,
      chapterEnd: json['chapterEnd'] as int? ?? json['chapter_end'] as int? ?? 0,
      verseStart: json['verseStart'] as int? ?? json['verse_start'] as int? ?? 0,
      verseEnd: json['verseEnd'] as int? ?? json['verse_end'] as int? ?? 0,
      sectionId: json['sectionId'] as String? ?? json['section_id'] as String,
      topic: json['topic'] as String,
      storyEventId: json['storyEventId'] as String? ?? json['story_event_id'] as String,
      conceptTags: List<String>.from((json['conceptTags'] ?? json['concept_tags'] ?? <String>[]) as List<dynamic>),
      questionType: json['questionType'] as String? ?? json['question_type'] as String,
      difficulty: json['difficulty'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
      acceptedAnswers: List<String>.from(json['acceptedAnswers'] as List<dynamic>),
      choices: List<String>.from(json['choices'] as List<dynamic>),
      hints: List<String>.from(json['hints'] as List<dynamic>),
      explanation: json['explanation'] as String,
      reference: json['reference'] as String,
      translationNotice: json['translationNotice'] as String? ?? '',
      contentStatus: json['contentStatus'] as String? ?? 'needs_review',
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
